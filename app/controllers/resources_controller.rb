# frozen_string_literal: true

# controller for the Resource class
class ResourcesController < ApplicationController
  require 'will_paginate/array'

  unless Rails.env.preview?
    http_basic_authenticate_with name: Rails.application.credentials.import['name'],
                                 password: Rails.application.credentials.import['password'], only: ['import']
  end

  def alias
    logger.warn("here we are in the alias action")
    @resource = SearchResult.displayed.find_by(alias: params[:alias])
    logger.warn("we found a resource and its #{@resource.slug}")
    redirect_to "/items/#{@resource.slug}"
  end
  
  def show
    @resource = scoped_resources.find_by(slug: params[:id])
    @resource ||= scoped_resources.find(params[:id])
    redirect_to "/pages/#{@resource.slug}" if @resource.is_a?(Page)
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
    @resources += SearchResult.algolia_search(search_string, hitsPerPage: 1000, page: 1)
    @total = @resources.size
    @resources = @resources.paginate(page:, per_page: (params[:view] == 'all' ? @total : 25))
    render 'index'
  end

  def authors
    @authors = Author.displayed.order('alphabetized_name ASC, first_name ASC')
    @page = Page.displayed.find_by(name: 'Contributors')
  end

  private

  def populate_resources
    set_filters
    @resources = scoped_resources
    @resources = scoped_resources.joins(:searchresults_topics).with_topic(@topic) if @topic
    @resources = scoped_resources.with_category(@category) if @category
    @resources = scoped_resources.with_author(@author) if @author
    @resources = @resources.standard_scope
    @latest = params[:recent].to_s == 'true'
    @resources = SearchResult.displayed.published.where.not(type: 'Page').order('published_at desc') if @latest

    @total = @resources.size
    @resources = if params[:view] != 'all'
                   @resources.paginate(page: @page_num, per_page: 75)
                 else
                   @resources.paginate(page: @page_num, per_page: @resources.size)
                 end
  end

  def set_filters
    category = params[:category]
    topic = params[:topic]
    author = params[:author]
    track = params[:track]
    @category = Category.displayed.find(category) if category
    @topic = Topic.displayed.find(topic) if topic
    @author = Author.displayed.find(author) if author
    @track = Track.displayed.find(track) if track
    @page_num = params[:page] ? params[:page].to_i : 1
  end
end
