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

  def show
    @title='დავალების თვისებები'
    @task = Task.find(params[:id])
  end

  def edit
    @title='რედაქტირება'
    @task = Task.find(params[:id])
    if request.post?
      if @task.update_attributes(params.require(:task).permit(:note, :assignee_id))
        redirect_to tasks_task_url(id: @task.id), notice: 'დავალება შეცვლილია'
      end
    end
  end

  def destroy
    task = Task.find(params[:id])
    if task.can_delete?
      task.destroy
      redirect_to tasks_open_url, notice: 'დავალება წაშლილია'
    else
      redirect_to tasks_task_url(id: task.id), alert: 'ამ დავალებას ვერ წავშლი'
    end
  end

  def begin_task
    task = Task.find(params[:id])
    if task.can_begin?
      task.begin
      redirect_to tasks_task_url(id: task.id), notice: 'დავალება დაწყებულია'
    else
      redirect_to tasks_task_url(id: task.id), alert: 'დავალებას ვერ დავიწყებ'
    end
  end

  def cancel_task
    task = Task.find(params[:id])
    if task.can_cancel?
      task.cancel
      redirect_to tasks_task_url(id: task.id), notice: 'დავალება გაუქმებულია'
    else
      redirect_to tasks_task_url(id: task.id), alert: 'დავალებას ვერ გავაუქმებ'
    end
  end

  def complete_task
    task = Task.find(params[:id])
    if task.can_cancel?
      task.complete
      redirect_to tasks_task_url(id: task.id), notice: 'დავალება დასრულებულია'
    else
      redirect_to tasks_task_url(id: task.id), alert: 'დავალებას ვერ დავასრულებ'
    end
  end

  protected
  def nav
    @nav=super
    @nav['ღია დავალებები']=tasks_open_url
    unless ['open'].include?(action_name)
      @nav['ყველა დავალება']=tasks_all_url unless ['all'].include?(action_name)
      @nav["დავალება ##{@task.number}"]=tasks_task_url(id:@task.id) if (@task and not [ 'show' ].include?(action_name))
      @nav[@title]=nil
    end
  end
end