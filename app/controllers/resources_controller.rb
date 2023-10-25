# frozen_string_literal: true

# controller for the Resource class
class ResourcesController < ApplicationController
  require 'will_paginate/array'

  if Rails.env != 'preview'
    http_basic_authenticate_with name: Rails.application.credentials.import['name'],
                                 password: Rails.application.credentials.import['password'], only: ['import']
  end

  def show
    @resource = scoped_resources.find(params[:id])
    redirect_to "/events/#{@resource.slug}" if @resource.is_a?(Event)
    redirect_to "/blog_posts/#{@resource.slug}" if @resource.is_a?(BlogPost)
  end

  def index
    populate_resources
    respond_to do |format|
      format.html
      format.js
      format.rss do
        @resources = scoped_resources.rss
        render layout: false
      end
    end
  end

  def search
    search_string = params[:search_string]
    page = params[:page] ? params[:page].to_i : 1

    @search = search_string
    @resources = []
#    (1..50).each do |i|
      @resources += SearchResult.algolia_search(search_string, hitsPerPage: 1000, page: 1)
    #   @resources += @results
    # end
    @resources = if params[:view] != 'all'
                   @resources.paginate(page:, per_page: 25)
                 else
                   @resources.paginate(page:, per_page: @resources.size)
                 end

    render 'index'
    end

  def authors
    @authors = Author.displayed.order('alphabetized_name ASC, first_name ASC')
    @page = Page.displayed.find_by_name('Contributors')
  end

  private

  def populate_resources
    set_filters
    @resources = scoped_resources
    @resources = scoped_resources.joins(:searchresults_topics).with_topic(@topic) if @topic
    @resources = scoped_resources.with_category(@category) if @category
    @resources = scoped_resources.with_author(@author) if @author
    @resources = @resources.standard_scope
    @total = @resources.size
    return unless @resources.size > 75 && params[:view] != 'all'

    @resources = @resources.first(75)
  end

  def paginate
    @resources = if params[:view] == 'all'
                   @resources.paginate(page: 1, per_page: @resources.size)
                 else
                   @resources.paginate(page: params[:page], per_page: 75)
                 end
  end

  def set_filters
    category = params[:category]
    topic = params[:topic]
    author = params[:author]
    @category = Category.displayed.find(category) if category
    @topic = Topic.displayed.find(topic) if topic
    @author = Author.displayed.find(author) if author
  end
end
