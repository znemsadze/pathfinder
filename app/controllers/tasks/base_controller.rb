# -*- encoding : utf-8 -*-
class Tasks::BaseController < ApplicationController
  def index
    @title='ღია დავალებები'
    @tasks = Task.open_tasks.desc(:_id).paginate(per_page: 25)
  end

  protected
  def nav
    @nav=super
    @nav['დავალებები']=tasks_home_url
    @nav[@title]=nil unless ['index'].include?(action_name)
  end
end