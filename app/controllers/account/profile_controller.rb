# -*- encoding : utf-8 -*-
class Account::ProfileController < ApplicationController
  def index; @title=t('pages.account_profile.index.title') end

  protected
  def nav
    @nav=super
    @nav[t('pages.account_profile.index.title')]=account_profile_url
    @nav[@title]=request.url
    @nav
  end
end
