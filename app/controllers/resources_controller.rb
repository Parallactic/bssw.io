# frozen_string_literal: true

# controller for the Resource class
class ResourcesController < ApplicationController
  require 'will_paginate/array'

  unless Rails.env.preview?
    http_basic_authenticate_with name: Rails.application.credentials.import['name'],
                                 password: Rails.application.credentials.import['password'], only: ['import']
  end

  def alias
    @resource = SearchResult.displayed.find_by(alias: params[:alias])
    redirect_to "/items/#{@resource.slug}"
  end

  def show
    @resource = scoped_resources.find_by(slug: params[:id])
    @resource ||= scoped_resources.find(params[:id])
    [Page, Event, BlogPost].each do |kind|
      redirect_to "/#{kind.snake_case.pluralize}/#{@resource.slug}" if @resource.is_a?(kind)
    end
  end

  def index
    populate_resources

    respond_to do |format|
      format.html
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

    set_resources
    @resources = @resources.standard_scope

    @resources = SearchResult.displayed.published.where.not(type: 'Page').order('published_at desc') if @latest

    @total = @resources.size
    @resources = if params[:view] != 'all'
                   @resources.paginate(page: @page_num, per_page: 75)
                 else
                   @resources.paginate(page: @page_num, per_page: @resources.size)
                 end
  end

  def set_resources
    @resources = scoped_resources
    @resources = scoped_resources.joins(:searchresults_topics).with_topic(@topic) if @topic
    @resources = scoped_resources.with_category(@category) if @category
    @resources = scoped_resources.with_author(@author) if @author
  end

  def set_filters
    set_associations

    @page_num = params[:page] ? params[:page].to_i : 1
    @latest = params[:recent].to_s == 'true'
  end

  def set_associations
    @category = Category.displayed.find(params[:category]) if params[:category]
    @topic = Topic.displayed.find(params[:topic]) if params[:topic]
    @author = Author.displayed.find(params[:author]) if params[:author]
    @track = Track.displayed.find(params[:track]) if params[:track]
  end
end
