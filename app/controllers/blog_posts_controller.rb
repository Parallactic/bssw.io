# frozen_string_literal: true

# display blog
class BlogPostsController < ApplicationController
  def index
    @page = Page.displayed.find_by(name: 'BSSw Blog')
    author = params[:author]
    @posts = scoped_resources.blog
    if author
      @posts = @posts.with_author(Author.find_by(slug: author, rebuild_id: RebuildStatus.first.display_rebuild_id))
    end
    @posts = @posts.paginate(page: params[:page], per_page: 25)
  end

  def show
    blog = scoped_resources.blog
    @post = blog.find(params[:id])
    @resource = @post
    @related_posts = @post.related_posts
  end
end
