# frozen_string_literal: true

# display content pages
class PagesController < ApplicationController
  def show
    @page = if params[:id] == 'about'
              Page.displayed.find_by(slug: 'team')
            else
              Page.displayed.find_by(slug: params[:id])
            end
    raise ActionController::RoutingError, 'Not Found' unless @page

    set_quote
    @contribute = Contribute.new
    redirect_to action: 'new', controller: 'contacts' if @page.name == 'Contact BSSw'
  end

  def set_quote
    @quote = Quote.displayed.find(Quote.displayed.pluck(:id).sample) unless Quote.displayed.empty? || !@page.home?
  end
end
