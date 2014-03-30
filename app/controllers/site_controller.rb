# -*- encoding : utf-8 -*-
class SiteController < ApplicationController
  def index
    @title = t('pages.site.index.title')
  end
end
