# frozen_string_literal: true

# display categories
class CategoriesController < ApplicationController
  def show
    # suspect we don't use this but rather use the 'resources' page
    # leaving here until confirmed
    @category = Category.find(params[:id])
  end
end
