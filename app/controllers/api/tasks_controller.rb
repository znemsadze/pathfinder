# -*- encoding : utf-8 -*-
require 'json'

class Api::TasksController < ApiController
  def index
    authenticate do |user|
      @tasks = Task.where(assignee: user).desc(:_id).paginate(per_page: 10, page: params[:page])
    end
  end

  def new
    assignee = Sys::User.find(params[:assignee_id])
    destinations = params[:destinations].map{|k,v| v}
    paths = params[:paths].map{|k,v| v.map{|k,v| v }}
    task = Task.create(assignee: assignee, note: params[:note], paths: paths, destinations: destinations)
    render json: {number: task.number}
  end
end
