# frozen_string_literal: true

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
    @github ||= Octokit::Client.new(access_token: Rails.application.credentials[:github][:token])
  end

  # Returns a path to a private copy of the content archive; the rebuild
  # pipeline deletes that copy when it finishes. The archive for a given
  # commit never changes, so we keep the download and reuse it.
  def self.save_content(branch, rebuild)
    rebuild.update(commit_hash: github.commit(Rails.application.credentials[:github][:repo], branch)['sha'])
    file_path = Rails.root.join("/tmp/repo-#{branch}-#{rebuild.commit_hash}-#{Time.now.to_i}.tar.gz")
    FileUtils.cp(cached_archive(branch, rebuild.commit_hash), file_path)
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
    agent.get(github.archive_link(Rails.application.credentials[:github][:repo], ref: sha)).save!(partial)
    File.rename(partial, path)
  ensure
    FileUtils.rm_f(partial) if partial
  end

  def self.agent
    agent = Mechanize.new
    agent.pluggable_parser.default = Mechanize::Download
    agent
  end

  def self.tar_extract(file_path)
    tar = Gem::Package::TarReader.new(Zlib::GzipReader.open(file_path))
    tar.rewind
    tar
  end

  def self.included_file(file)
    (File.extname(file.full_name) == '.md') &&
      !GithubImporter.excluded_filenames.include?(File.basename(file.full_name))
  end

  def self.populate(branch)
    rebuild = RebuildStatus.in_progress_rebuild
    file_path = save_content(branch, rebuild)
    tar_extract(file_path).each do |file|
      rebuild.process_file(file) if included_file(file)
    rescue StandardError
      # fail silently?
    end
    RebuildStatus.complete(rebuild, file_path)
  ensure
    FileUtils.rm_f(file_path) if file_path
  end

end
