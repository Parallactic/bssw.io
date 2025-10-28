# frozen_string_literal: true

# Announcements in top bar
class AnnouncementsController < ApplicationController
  def close
    session[:hide_announcement] = true
  end
end
