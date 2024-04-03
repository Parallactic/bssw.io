# frozen_string_literal: true

# display blog
class BlogPostsController < ApplicationController
  def index
    set_variables
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
    blog = scoped_resources.blog
    @post = blog.find(params[:id])
    @resource = @post
    @related_posts = @post.related_posts
  end

  private

  def set_variables
    @page = Page.displayed.find_by(name: 'BSSw Blog')
    @author = Author.displayed.find_by(slug: params[:author]) if params[:author]
    @track = Track.displayed.find(params[:track]) if params[:track]
    @posts = scoped_resources.blog
    @all = (params[:view] == 'all')
  end
end
