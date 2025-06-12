# frozen_string_literal: true

# display blog
class BlogPostsController < ApplicationController
  def index
    set_variables
    session[:path] = nil
@posts = scoped_resources.blog
    if @author
      @posts = @posts.with_author(@author)
    elsif @track
      @posts = @posts.with_track(@track.id)
    end
    @total = @posts.size
    @posts = @posts.paginate(page: (@all ? 1 : params[:page]), per_page: (@all ? @total : 25))
    render(@track.nil? ? :index : :track)
  end

  def show
    puts "bloggity"
    #    blog = scoped_resources.blog
    #    @post = blog.find(params[:id])
@resource = scoped_resources.find_by(slug: params[:id])
    @resource ||= scoped_resources.find(params[:id])
    puts "were in the blog"
puts @resource.inspect
    @post = @resource

    @related_posts = @post.related_posts
  end

  private

  def set_variables
    @page = Page.displayed.find_by(name: 'BSSw Blog')
    @author = Author.displayed.find_by(slug: params[:author]) if params[:author]
    @track = Track.displayed.find(params[:track]) if params[:track]

    @all = (params[:view] == 'all')
  end
end
