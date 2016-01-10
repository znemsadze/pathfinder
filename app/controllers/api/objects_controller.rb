# -*- encoding : utf-8 -*-
class Api::ObjectsController < ApiController
  MAX_TOWERS=100_000

  def index
    if params[:id].blank?

      s = Rails.cache.fetch(Sys::Cache::MAPJSON) do
        json = Sys::Cache.map_objects
        render_to_string( template: 'api/objects/index.json.jbuilder', json: json )
      end

      render :json => s
    else
      json = Objects::GeoJson.geo_json(get_all_objects)
      render json: json
    end
  end

  def lines; @objects = get_lines ; render action: 'index' end
  def pathlines; @objects = get_paths ; render action: 'index' end
  def offices; @objects = get_offices ; render action: 'index' end
  def substations; @objects = get_substations ; render action: 'index' end
  def towers; @objects = Objects::Tower.paginate(per_page: 500, page: params[:page]) ; render action: 'index' end

  private

  def get_all_objects
    get_towers + get_offices + get_substations + get_lines + get_paths
  end

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
