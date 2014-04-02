# -*- encoding : utf-8 -*-
class Admin::RolesController < ApplicationController
  def index
    @title=t('pages.admin_roles.index.title')
    @roles=Sys::Role.asc(:name).paginate(page:params[:page], per_page:10)
  end

  def show
    @title=t('pages.admin_roles.show.title')
    @role=Sys::Role.find(params[:id])
  end

  def new
    @title=t('pages.admin_roles.new.title')
    if request.post?
      @role=Sys::Role.new(role_params)
      if @role.save(user:current_user)
        redirect_to admin_role_url(id:@role.id), notice:t('pages.admin_roles.new.role_created')
      end
    else
      @role=Sys::Role.new
    end
  end

  def edit
    @title=t('pages.admin_roles.edit.title')
    @role=Sys::Role.find(params[:id])
    if request.post?
      if @role.update_attributes(role_params.merge(user:current_user))
        redirect_to admin_role_url(id:@role.id), notice:t('pages.admin_roles.edit.role_updated')
      end
    end
  end

  def destroy
    role=Sys::Role.find(params[:id])
    role.destroy
    redirect_to admin_roles_url, notice: t('pages.admin_roles.destroy.role_destroied')
  end

  def add_user
    @title=t('models.sys_role._actions.add_user')
    @role=Sys::Role.find(params[:id])
    if request.post?
      user=Sys::User.where(username:params[:username]).first
      if user
        @role.users<<user
        redirect_to admin_role_url(id:@role.id,tab:'users'), notice:t('pages.admin_roles.add_user.user_added')
      else
        @error=t('pages.admin_roles.add_user.user_not_found')
      end
    end
  end

  def remove_user
    role=Sys::Role.find(params[:id])
    user=Sys::User.find(params[:user_id])
    role.users.delete(user)
    redirect_to admin_role_url(id:role.id,tab:'users'), notice:t('pages.admin_roles.remove_user.user_removed')
  end

  protected
  def nav
    @nav=super
    @nav[t('pages.admin_roles.index.title')]=admin_roles_url
    if @role
      @nav[@role.name]=admin_role_url(id:@role.id) unless @role.new_record?
      @nav[@title]=request.url unless action_name=='show'
    end
  end

  private
  def role_params; params.require(:sys_role).permit(:name,:description) end
end
