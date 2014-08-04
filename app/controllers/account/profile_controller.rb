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

  def change_password
    @title = 'პაროლის შეცვლა'
    if request.post?
      user = Sys::User.authenticate(current_user.username, params[:password_old])
      if user
        password = params[:password]
        password_confirmation = params[:password_confirmation]
        if password.blank?
          @error = 'ჩაწერეთ ახალი პაროლი'
        elsif password_confirmation != password
          @error = 'პაროლი არ ემთხვევა დადასტურებას'
        elsif user.update_attributes(password: password, password_confirmation: password_confirmation)
          redirect_to account_profile_url, notice: 'პაროლი შეცვლილია'
        else
          @error = user.errors.full_messages.join(', ')
        end
      else
        @error = 'თქვენი ძველი პაროლი არაა სწორი'
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

  def login_required; true end
end
