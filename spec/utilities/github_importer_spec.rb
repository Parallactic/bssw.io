# frozen_string_literal: true

require 'rails_helper'
require 'socket'

RSpec.describe GithubImporter do
  # Minimal HTTP server on localhost so stream_to_file exercises real Net::HTTP
  # without touching GitHub. Serves every request with the given status/body.
  def with_http_server(status:, body:)
    server = TCPServer.new('127.0.0.1', 0)
    thread = Thread.new do
      loop do
        client = server.accept
        while (line = client.gets) && line != "\r\n"; end # drain request headers
        client.write("HTTP/1.1 #{status}\r\nContent-Length: #{body.bytesize}\r\n" \
                     "Content-Type: application/octet-stream\r\nConnection: close\r\n\r\n")
        client.write(body)
        client.close
      end
    rescue IOError
      nil # server closed
    end
    yield "http://127.0.0.1:#{server.addr[1]}/archive.tar.gz"
  ensure
    server&.close
    thread&.kill
  end

  let(:cache_dir) { Rails.root.join("tmp/spec_github_archives_#{Process.pid}") }
  let(:body) { Random.bytes(3_000_000) } # big enough to arrive in several chunks

  before { allow(described_class).to receive(:archive_cache_dir).and_return(cache_dir) }
  after { FileUtils.rm_rf(cache_dir) }

  describe '.stream_to_file' do
    let(:target) { cache_dir.join('out.tar.gz') }

    before { FileUtils.mkdir_p(cache_dir) }

    it 'writes the response body to the file' do
      with_http_server(status: '200 OK', body: body) do |url|
        expect { described_class.stream_to_file(url, target) }.to output(/Status: 200, size: 3 MB/).to_stdout
      end
      expect(File.binread(target)).to eq(body)
    end

    it 'raises on a non-2xx response and writes nothing' do
      with_http_server(status: '404 Not Found', body: 'nope') do |url|
        expect do
          expect { described_class.stream_to_file(url, target) }.to output.to_stdout
        end.to raise_error(Net::HTTPClientException)
      end
      expect(File).not_to exist(target)
    end
  end

  describe '.download_archive' do
    let(:sha) { 'abc123' }
    let(:path) { cache_dir.join("repo-main-#{sha}.tar.gz") }
    let(:client) { instance_double(Octokit::Client) }

    before { allow(described_class).to receive(:github).and_return(client) }

    it 'downloads the archive for the sha into the path, leaving no partial file' do
      with_http_server(status: '200 OK', body: body) do |url|
        allow(client).to receive(:archive_link)
          .with(Rails.application.credentials[:github][:repo], ref: sha).and_return(url)
        expect { described_class.download_archive(sha, path) }.to output.to_stdout
      end
      expect(File.binread(path)).to eq(body)
      expect(Dir.glob(cache_dir.join('*.part'))).to be_empty
    end

    it 'cleans up the partial file and leaves no archive when the download fails' do
      with_http_server(status: '500 Internal Server Error', body: 'boom') do |url|
        allow(client).to receive(:archive_link).and_return(url)
        expect do
          expect { described_class.download_archive(sha, path) }.to output.to_stdout
        end.to raise_error(Net::HTTPFatalError)
      end
      expect(File).not_to exist(path)
      expect(Dir.glob(cache_dir.join('*.part'))).to be_empty
    end
  end

  describe '.cached_archive' do
    let(:path) { cache_dir.join('repo-main-new.tar.gz') }

    before { FileUtils.mkdir_p(cache_dir) }

    it 'returns the cached archive without downloading when present' do
      File.write(path, 'cached')
      allow(described_class).to receive(:download_archive)

      expect(described_class.cached_archive('main', 'new')).to eq(path)
      expect(described_class).not_to have_received(:download_archive)
    end

    it 'downloads on a miss and drops older archives for the same branch only' do
      stale = cache_dir.join('repo-main-old.tar.gz')
      other_branch = cache_dir.join('repo-preview-old.tar.gz')
      [stale, other_branch].each { |f| File.write(f, 'x') }
      allow(described_class).to receive(:download_archive) { |_sha, p| File.write(p, 'fresh') }

      expect(described_class.cached_archive('main', 'new')).to eq(path)
      expect(described_class).to have_received(:download_archive).with('new', path)
      expect(File.read(path)).to eq('fresh')
      expect(File).not_to exist(stale)
      expect(File).to exist(other_branch)
    end
  end
end
