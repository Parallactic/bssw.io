# frozen_string_literal: true

# show list of communities and individual pages
class CommunitiesController < ApplicationController
  def show
    @community = Community.displayed.find(params[:id])
    @resource = @community
  end
end
