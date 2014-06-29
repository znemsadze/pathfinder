# -*- encoding : utf-8 -*-
class Tasks::TrackingController < ApplicationController
  def index
    @title='მომხმარებელთა ტრეკინგი'
    @users=Sys::User.all.asc(:username)
  end

  def user
    @user=Sys::User.find(params[:id])
    @title=@user.full_name
    @tracks=Tracking::Path.where(user:@user).desc(:_id).paginate(per_page: 10, page: params[:page])
  end

  protected
  def nav
    @nav=super
    @nav['მომხმარებელთა ტრეკინგი']=tasks_tracking_url
    @nav[@title]=nil unless ['index'].include?(action_name)
  end
end