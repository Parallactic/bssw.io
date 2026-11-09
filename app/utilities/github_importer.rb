# frozen_string_literal: true

require 'net/http'

# utility methods for the import
class GithubImporter < ApplicationRecord
  self.abstract_class = true

  def self.excluded_filenames
    ['README.md', 'LICENSE', '.gitignore', 'Abbreviations.md', 'CODE_OF_CONDUCT.md', 'CONTRIBUTING.md', 'index.md']
  end

  def self.parse_html_from(updated_content)
    markdown = Redcarpet::Markdown.new(RougeRenderer.new(with_toc_data: true),
                                       autolink: true,
                                       tables: true,
                                       lax_spacing: true,
                                       strikethrough: true,
                                       fenced_code_blocks: true,
                                       no_intra_emphasis: true)
    Nokogiri::HTML(markdown.render(updated_content), nil, 'UTF-8')
  end

  def self.normalized_path(path)
    new_path = path.split('/')
    new_path.shift
    new_path.join('/')
  end

  # Reuse one client so its HTTP connection stays open across calls
  # (see config/initializers/octokit.rb).
  def self.github
    token = Rails.application.credentials[:github][:token]
    client = Thread.current[:github_client]
    return client if client && client.access_token == token

    Thread.current[:github_client] = Octokit::Client.new(access_token: token)
  end
  # def self.github
  #   Octokit::Client.new(access_token: Rails.application.credentials[:github][:token])
  # end

  # Returns a path to a private copy of the content archive; the rebuild
  # pipeline deletes that copy when it finishes. The archive for a given
  # commit never changes, so we keep the download and reuse it.
  def self.save_content(branch, rebuild)
    Rails.logger.debug 'getting'
    rebuild.update(commit_hash: github.commit(Rails.application.credentials[:github][:repo], branch)['sha'])
    file_path = Rails.root.join("tmp/repo-#{branch}-#{rebuild.commit_hash}-#{Time.now.to_i}.tar.gz").to_s
    FileUtils.cp(cached_archive(branch, rebuild.commit_hash), file_path)
    Rails.logger.debug 'got'
    file_path
  end

  def self.archive_cache_dir
    Rails.root.join('tmp/github_archives')
  end

  # Downloads the archive for this commit unless it's already cached, and
  # drops archives of older commits on the same branch.
  def self.cached_archive(branch, sha)
    path = archive_cache_dir.join("repo-#{branch}-#{sha}.tar.gz")
    return path if File.exist?(path)

    download_archive(sha, path)
    Dir.glob(archive_cache_dir.join("repo-#{branch}-*.tar.gz")).each do |f|
      FileUtils.rm_f(f) unless f == path.to_s
    end
    path
  end

  # Writes to a .part file first so an interrupted download is never reused.
  def self.download_archive(sha, path)
    FileUtils.mkdir_p(path.dirname)
    partial = path.sub_ext(".#{Process.pid}.part")
    stream_to_file(github.archive_link(Rails.application.credentials[:github][:repo], ref: sha), partial)
    File.rename(partial, path)
  ensure
    FileUtils.rm_f(partial) if partial
  end

  def self.stream_to_file(url, file_path)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https',
                                        open_timeout: 30, read_timeout: 60) do |http|
      puts uri
      http.request_get(uri) do |res|
        res.value # raises unless 2xx
        print "Status: #{res.code}, size: #{res['content-length'].to_i / 1_000_000} MB"
        total = 0
        File.open(file_path, 'wb') do |f|
          res.read_body do |chunk|
            f.write(chunk)
            total += chunk.size
            print "\r#{total / 1_000_000} MB"
          end
        end
      end
    end
  end

  # def self.agent
  #   agent = Mechanize.new
  #   agent.pluggable_parser.default = Mechanize::Download
  #   agent
  # end

  def self.tar_extract(file_path, &block)
    Zlib::GzipReader.open(file_path) do |gz|
      Gem::Package::TarReader.new(gz) do |tar|
        tar.each(&block)
      end
    end
  end

  def self.included_file(file)
    (File.extname(file.full_name) == '.md') &&
      !GithubImporter.excluded_filenames.include?(File.basename(file.full_name))
  end

  def self.populate(branch)
    rebuild = RebuildStatus.in_progress_rebuild
    file_path = save_content(branch, rebuild)
    puts "extracting from #{file_path}"
    tar_extract(file_path) do |file|
      print '.'
      rebuild.process_file(file) if included_file(file)
    end
    puts "completed!! #{rebuild.id}"
    RebuildStatus.complete(rebuild, file_path)
  ensure
    FileUtils.rm_f(file_path) if file_path
  end

end
