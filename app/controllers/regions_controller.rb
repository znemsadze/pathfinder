# -*- encoding : utf-8 -*-
class RegionsController < ApplicationController
  def index
    @title='რეგიონები'
    @regions=Region.asc(:name)
  end

  def new
    @title='ახალი რეგიონი'
    if request.post?
      @region=Region.new(region_params)
      if @region.save(user:current_user)
        redirect_to region_url(id:@region.id), notice: 'რეგიონი შექმნილია'
      end
    else
      @region=Region.new
    end
  end

  def delete
    region=Region.find(params[:id])
    if region.can_delete?
      region.destroy
      redirect_to regions_url, notice: 'რეგიონი წაშლილია'
    else
      redirect_to region_url(id:region.id), notice: 'წაშლა დაუშვებელია: დაკავშირებული ობიექტები'
    end
  end

  protected
  def nav
    @nav=super
    @nav['რეგიონები']=regions_url
  end

  private
  def region_params; params.require(:region).permit(:name,:description) end
end
