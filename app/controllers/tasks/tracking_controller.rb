# -*- encoding : utf-8 -*-
class Tasks::TrackingController < ApplicationController
  def index
    @title = 'მომხმარებელთა ტრეკინგი'
    @users = Sys::User.all.asc(:username)
    @last_tracks = @users.map{|user| Tracking::Path.where(user: user).last }.compact
  end

  def user
    @user=Sys::User.find(params[:id])
    @title=@user.full_name
    @tracks=Tracking::Path.where(user:@user).desc(:_id).paginate(per_page: 10, page: params[:page])
  end

  def track
    @track = Tracking::Path.find(params[:id])
    respond_to do |format|
      format.html do
        @user = @track.user
        @title = "ტრეკი: #{@track.created_at.localtime.strftime('%d-%b-%Y %H:%M:%S')} / #{@track.updated_at.localtime.strftime('%d-%b-%Y %H:%M:%S')}"
      end
      format.kml { render text: @track.to_kml }
      format.kmz {
        # raise "#{@track.to_kmz.class.name}"
        send_data @track.to_kmz, filename: "track-#{@track.user.username}-#{@track.created_at.strftime('%Y%m%d')}.kmz"
        # render text: @track.to_kmz, filename: 'test.kmz'
      }
    end
  end

  protected
  def nav
    @nav=super
    @nav['მომხმარებელთა ტრეკინგი']=tasks_tracking_url
    @nav[@track.user.full_name]=tasks_tracking_user_url(id:@track.user) if @track
    @nav[@title]=nil unless ['index'].include?(action_name)
  end
end
