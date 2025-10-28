# frozen_string_literal: true

# send email via contact form
class ContributesController < ApplicationController
  before_action :set_page
  invisible_captcha only: [:create]

  def new
    @contribute = Contribute.new
  end

  def create
    @contribute = Contribute.new(params[:contribute])
    process_message(@contribute)
    render 'pages/show'
  end

  private

  def set_page
    @page = Page.find_by(
      name: 'Questions About Contributing to Better Scientific Software?'
    )
  end
end
