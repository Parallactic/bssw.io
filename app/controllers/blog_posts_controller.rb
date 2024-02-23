# frozen_string_literal: true

# display blog
class BlogPostsController < ApplicationController
  def index
    @page = Page.displayed.find_by(name: 'BSSw Blog')
    author = params[:author]
    @track = Track.displayed.find(params[:track]) if params[:track]
    @posts = scoped_resources.blog
    @posts = @posts.with_track(@track.id) if @track
    if author
      @posts = @posts.with_author(Author.find_by(slug: author,
                                                 rebuild_id: RebuildStatus.first.display_rebuild_id))
    end
    @total = @posts.size
    @posts = if params[:view] == 'all'
               @posts.paginate(page: 1, per_page: @posts.size)
             else
               @posts.paginate(page: params[:page], per_page: 25)
             end
    if @track
      render :track
    else
      render :index
    end
  end

  def show
    blog = scoped_resources.blog
    @post = blog.find(params[:id])
    @resource = @post
    @related_posts = @post.related_posts
  end
end
