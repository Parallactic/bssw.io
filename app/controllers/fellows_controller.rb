# frozen_string_literal: true

# display Fellow bio info
class FellowsController < ApplicationController
  def index
    @fellows = Fellow.displayed
  end

  def show
    @fellow = Fellow.displayed.where(
      honorable_mention: nil
    ).or(
      Fellow.displayed.where(honorable_mention: false)
    ).find(params[:id])
    render :show
  end
end
