# -*- encoding : utf-8 -*-
class Api::ObjectsController < ApiController
  MAX_TOWERS=100_000

  caches_action :index, if: -> { params[:id].blank? }
  caches_action :lines, :pathlines, :offices, :substations
  # don't cache towers!

  def index; @objects = get_towers + get_offices + get_substations + get_lines + get_paths end
  def lines; @objects = get_lines ; render action: 'index' end
  def pathlines; @objects = get_paths ; render action: 'index' end
  def offices; @objects = get_offices ; render action: 'index' end
  def substations; @objects = get_substations ; render action: 'index' end
  def towers; @objects = Objects::Tower.paginate(per_page: 500, page: params[:page]) ; render action: 'index' end

  # TODO: get towers "near" given point
  # def towers; @objects = get_towers ; render action: 'index' end 

  private

  def get_towers
    if params[:type].blank?
      Objects::Tower.all.paginate(per_page:MAX_TOWERS)
    elsif params[:type]=='Objects::Tower'
      rel=Objects::Tower
      rel=rel.in(_id:params[:id].split(',')) if params[:id].present?
      rel.all.paginate(per_page:MAX_TOWERS)
    else
      []
    end
  end

  def get_offices
    if params[:type].blank?
      Objects::Office.all
    elsif params[:type]=='Objects::Office'
      rel=Objects::Office
      rel=rel.in(_id:params[:id].split(',')) if params[:id].present?
      rel.all
    else
      []
    end
  end

  def get_substations
    if params[:type].blank?
      Objects::Substation.all
    elsif params[:type]=='Objects::Substation'
      rel=Objects::Substation
      rel=rel.in(_id:params[:id].split(',')) if params[:id].present?
      rel.all
    else
      []
    end
  end

  def get_lines
    if params[:type].blank?
      Objects::Line.all
    elsif params[:type]=='Objects::Line'
      rel=Objects::Line
      rel=rel.in(_id:params[:id].split(',')) if params[:id].present?
      rel.all
    else
      []
    end
  end

  def get_paths
    if params[:type].blank?
      Objects::Path::Line.all
    elsif params[:type]=='Objects::Path::Line'
      rel=Objects::Path::Line
      rel=rel.in(_id:params[:id].split(',')) if params[:id].present?
      rel.all
    else
      []
    end
  end
end
