# -*- encoding : utf-8 -*-
class Api::ObjectsController < ApiController
  MAX_TOWERS=100

  def index; @all=get_towers+get_offices+get_lines+get_paths end

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
