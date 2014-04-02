# -*- encoding : utf-8 -*-
class Admin::RolesController < ApplicationController
  def index
    @title=t('pages.admin_roles.index.title')
    @roles=Sys::Role.desc(:_id).paginate(page:params[:page], per_page:10)
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
      if @role.update_attributes(role_params)
        redirect_to admin_role_url(id:@role.id), notice:t('pages.admin_roles.edit.role_updated')
      end
    end
  end

  protected
  def nav
    @nav=super
    @nav[t('pages.admin_roles.index.title')]=admin_roles_url
    if @role
      @nav[@role.name]=admin_role_url(id:@role.id) unless @role.new_record?
      @nav[@title]=nil unless action_name=='show'
    end
  end

  private
  def role_params; params.require(:sys_role).permit(:name,:description).merge(user:current_user) end
end
