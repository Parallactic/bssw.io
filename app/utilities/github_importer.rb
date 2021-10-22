
# frozen_string_literal: true

# utility methods for the import
class GithubImporter < ApplicationRecord
  self.abstract_class = true

  def self.excluded_filenames
    ['README.md', 'LICENSE', '.gitignore', 'Abbreviations.md', 'CODE_OF_CONDUCT.md', 'CONTRIBUTING.md', 'index.md']
  end

  def self.parse_html_from(updated_content)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                       autolink: true,
                                       tables: true,
                                       lax_spacing: true,
                                       disable_indented_code_blocks: true,
                                       fenced_code_blocks: true)
    Nokogiri::HTML(markdown.render(updated_content), nil, 'UTF-8')
  end

  def self.normalized_path(path)
    new_path = path.split('/')
    new_path.shift
    new_path.join('/')
  end

  def self.github
    Octokit::Client.new(access_token: Rails.application.credentials[:github][:token])
  end

  def self.save_content(branch, file_path)
    agent.get(github.archive_link(Rails.application.credentials[:github][:repo],
                                  ref: branch)).save(file_path)
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

  def self.populate(branch)
#    begin
    file_path = "#{Rails.root}/tmp/repo-#{branch}.gz"
    save_content(branch, file_path)
    rebuild = RebuildStatus.in_progress_rebuild
    tar_extract(file_path).each do |file|
      next if File.extname(file.full_name) != '.md'
      next if GithubImporter.excluded_filenames.include?(File.basename(file.full_name))
      rebuild.process_file(file)
    end

    RebuildStatus.complete(rebuild, file_path)
#    rescue Exception => e
#      puts e
#      puts "ERRORR"
#    end
  end
end