# frozen_string_literal: true

# display and perform rebuilds
class RebuildsController < ApplicationController
  if Rails.env != 'preview'
    http_basic_authenticate_with name: Rails.application.credentials[:import][:name],
                                 password: Rails.application.credentials[:import][:password]
  end

  before_action :check_rebuilds, only: ['import']

  def index
    @rebuilds = Rebuild.all
  end

  def make_displayed
    rs = RebuildStatus.first
    rs.update_attribute(:display_rebuild_id, params[:id])
    flash[:notice] = 'Reverted!'
    redirect_to '/rebuilds'
  end

  def import
    branch
    rebuild = Rebuild.create(started_at: Time.now, ip: request.ip)
    RebuildStatus.start(rebuild, @branch)
    GithubImporter.populate(@branch)
    flash[:notice] = 'Import completed!'
    redirect_to controller: 'rebuilds', action: 'index', rebuilt: true
  end

  private

  def branch
    @branch = if Rails.env.preview?
                'preview'
              elsif Rails.env.test?
                'master'
              else
                'master'
              end
  end

  def check_rebuilds
    return unless Rebuild.in_progress

    flash[:error] =
      'Another rebuild (started less than 10 minutes ago) is in progress.
        Please wait for this rebuild to complete, or wait 10 minutes to override.'
    redirect_to controller: 'rebuilds', action: 'index'
  end
end
