# -*- encoding : utf-8 -*-
class Tasks::TrackingController < ApplicationController
  def index
    @title='მომხმარებელთა ტრეკინგი'
    @users=Sys::User.all.asc(:username)
  end

  protected
  def nav
    @nav=super
    @nav['მომხმარებელთა ტრეკინგი']=tasks_tracking_url
    @nav[@title]=nil unless ['index'].include?(action_name)
  end
end