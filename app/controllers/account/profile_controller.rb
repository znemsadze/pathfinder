# -*- encoding : utf-8 -*-
class Account::ProfileController < ApplicationController
  def index; @title=t('pages.account_profile.index.title') end

  def edit
    @title=t('pages.account_profile.edit.title')
    @user=current_user
    if request.post?
      if @user.update_attributes(params.require(:sys_user).permit(:first_name,:last_name,:mobile).merge(user:current_user))
        redirect_to account_profile_url, notice: t('pages.account_profile.edit.saved')
      end
    end
  end

  protected
  def nav
    @nav=super
    @nav[t('pages.account_profile.index.title')]=account_profile_url
    @nav[@title]=request.url
    @nav
  end
end
