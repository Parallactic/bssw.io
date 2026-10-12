# frozen_string_literal: true

# display and perform rebuilds
class RebuildsController < ApplicationController
  if !Rails.env.preview? && !Rails.env.development?
    http_basic_authenticate_with name: Rails.application.credentials[:import][:name],
                                 password: Rails.application.credentials[:import][:password]
  end

  before_action :check_rebuilds, only: ['import']

  def index
    @rebuilds = Rebuild.all
  end

  def make_displayed
    puts "id is #{params[:id]}"
    rs = RebuildStatus.first
    rs.update(display_rebuild_id: params[:id])
    flash[:notice] = 'Reverted!'
    redirect_to '/rebuilds'
  end

  def import
    puts '...'
    branch
    puts '.....'
    rebuild = Rebuild.create(started_at: Time.zone.now, ip: request.ip)
    puts '........'
    RebuildStatus.start(rebuild, @branch)
    puts '...............'
    GithubImporter.populate(@branch)
    puts '..................'
    flash[:notice] = 'Import completed!'
    redirect_to controller: 'rebuilds', action: 'index', rebuilt: true
  end

  private

  def branch
    @branch = if Rails.env.preview?
                'preview'
              else
                'main'
              end
  end

  def check_rebuilds
    return unless Rebuild.in_progress

    puts 'another rebuild is in progress'
    flash[:error] =
      'Another rebuild (started less than 10 minutes ago) is in progress.
        Please wait for this rebuild to complete, or wait 10 minutes to override.'
    redirect_to controller: 'rebuilds', action: 'index'
  end
end
