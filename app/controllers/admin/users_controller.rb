# -*- encoding : utf-8 -*-
class Admin::UsersController < ApplicationController
  def index
    @title = t('pages.admin_users.index.title')
    @users = Sys::User.desc(:_id)
  end

  protected
  def nav
    @nav=super
    @nav[t('pages.admin_users.index.title')]=admin_users_url
  end
end
