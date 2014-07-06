# -*- encoding : utf-8 -*-
class Tasks::TrackingController < ApplicationController
  def index
    @title='მომხმარებელთა ტრეკინგი'
    @open_tracks = Tracking::Path.where(open: true)
    @users=Sys::User.all.asc(:username)
  end

  def user
    @user=Sys::User.find(params[:id])
    @title=@user.full_name
    @tracks=Tracking::Path.where(user:@user).desc(:_id).paginate(per_page: 10, page: params[:page])
  end

  def track
    @track=Tracking::Path.find(params[:id])
    @title="ტრეკი: #{@track.created_at.localtime.strftime('%d-%b-%Y %H:%M:%S')} / #{@track.updated_at.localtime.strftime('%d-%b-%Y %H:%M:%S')}"
  end

  protected
  def nav
    @nav=super
    @nav['მომხმარებელთა ტრეკინგი']=tasks_tracking_url
    @nav[@track.user.full_name]=tasks_tracking_user_url(id:@track.user) if @track
    @nav[@title]=nil unless ['index'].include?(action_name)
  end
end