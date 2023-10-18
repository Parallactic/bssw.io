# frozen_string_literal: true

# store the current rebuild
class RebuildStatus < ApplicationRecord
  def self.displayed_rebuild
    Rebuild.where(id: first.display_rebuild_id).first
  end

  def self.in_progress_rebuild
    Rebuild.where(id: first.in_progress_rebuild_id).first
  end

  def self.content_branch
    displayed_rebuild.content_branch
  end

  def self.code_branch
    first.code_branch
  end

  def self.commit_hash
    displayed_rebuild.commit_hash
  end

  def self.code_branch=(name)
    first.update(code_branch: name)
  end

  def self.start(rebuild, branch)
    begin
      Staff.all.each(&:delete)
      FellowLink.all.each(&:delete)
    rescue StandardError
    end
    rebuild.update(content_branch: branch)
    status = first || create
    status.update_attribute(:in_progress_rebuild_id, rebuild.id)
  end

  def self.complete(rebuild, file_path)
    first.update(display_rebuild_id: rebuild.id, in_progress_rebuild_id: nil)

    SiteItem.clean

    rebuild.clean(file_path)

    rebuild.update(files_processed: "<ul>#{rebuild.files_processed}</ul>",
                   ended_at: Time.now)
  end
end
