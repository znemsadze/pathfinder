# -*- encoding : utf-8 -*-
class Objects::PhotosController < ApplicationController
  def index
    @title = 'დაუდასტურებელი ფოტოები'
    @photos = Objects::Photo.where(confirmed: false)
  end

  protected
  def nav
    @nav = super
    @na
    @nav[@title] = nil
  end

  def login_required; true end
  def permission_required
    if ['generate_images'].include?(action_name) then not current_user.admin?
    elsif ['editor'].include?(action_name) then not current_user.editor
    else false end
  end
end
