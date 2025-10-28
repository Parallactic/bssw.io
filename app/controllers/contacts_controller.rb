# frozen_string_literal: true

# send email via contact form
class ContactsController < ApplicationController
  before_action :set_page
  invisible_captcha only: [:create]

  def new
    @contact = ContactForm.new
  end

  def create
    @contact = ContactForm.new(params[:contact_form])
    process_message(@contact)
    render :new
  end

  private

  def set_page
    @page = Page.displayed.where(name: 'Contact BSSw').first
  end
end
