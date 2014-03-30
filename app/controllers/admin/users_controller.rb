# -*- encoding : utf-8 -*-
class Admin::UsersController < ApplicationController
  def index
    @title=t('pages.admin_users.index.title')
    @users=Sys::User.desc(:_id)
  end

  def new
    @title=t('models.sys_user._actions.new_user')
    if request.post?
      @user=Sys::User.new(user_params)
      if @user.save
        redirect_to admin_users_url, notice: t('pages.admin_users.new.user_created')
      end
    else
      @user=Sys::User.new
    end
  end

  protected
  def nav
    @nav=super
    @nav[t('pages.admin_users.index.title')]=admin_users_url
    if @user
      @nav[@title]=nil
    end
  end

  private
  def user_params; params.require(:sys_user).permit(:username,:password,:first_name,:last_name,:mobile) end
end
