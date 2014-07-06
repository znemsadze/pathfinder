# -*- encoding : utf-8 -*-
class Tasks::BaseController < ApplicationController
  def open
    @title='ღია დავალებები'
    @tasks = Task.open_tasks.desc(:_id).paginate(per_page: 25)
  end

  def all
    @title='ყველა დავალება'
    @tasks = Task.desc(:_id).paginate(per_page: 25)
  end

  protected
  def nav
    @nav=super
    @nav['ღია დავალებები']=tasks_open_url
    @nav[@title]=nil unless ['open'].include?(action_name)
  end
end