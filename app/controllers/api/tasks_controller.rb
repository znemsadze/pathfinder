# -*- encoding : utf-8 -*-
require 'json'

class Api::TasksController < ApiController
  def index
    authenticate do |user|
      @tasks = Task.open_tasks.where(assignee: user).desc(:_id).paginate(per_page: 10, page: params[:page])
    end
  end

  def new
    assignee = Sys::User.find(params[:assignee_id])
    destinations = params[:destinations].map{|k,v| v}
    paths = params[:paths].map{|k,v| v.map{|k,v| v }}
    task = Task.create(assignee: assignee, note: params[:note], paths: paths, destinations: destinations)
    render json: {number: task.number}
  end

  def begin_task
    task = Task.find(params[:id])
    if task.can_begin?
      task.begin ; render json: { text: 'ok' }
    else
      render json: { error: 'ამ დავალებას ვერ დაიწყებთ: ჯერ დახურეთ სხვა დავალებები.' }
    end
  end

  def cancel_task
    task = Task.find(params[:id])
    if task.can_cancel?
      task.cancel ; render json: { text: 'ok' }
    else
      render json: { error: 'ამ დავალებას ვერ გააუქმებთ' }
    end
  end

  def complete_task
    task = Task.find(params[:id])
    if task.can_cancel?
      task.complete ; render json: { text: 'ok' }
    else
      render json: { error: 'ამ დავალებას ვერ დაასრულებთ' }
    end
  end

  def add_note
    task = Task.find(params[:id]) ; detail = Objects::Path::Detail.find(params[:detail_id])
    note = Objects::Note.create(task: task, detail: detail, lat: params[:lat].to_f, lng: params[:lng].to_f, note: params[:note])
    render json: { status: 'ok' }
  end
end
