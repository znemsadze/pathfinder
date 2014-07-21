# -*- encoding : utf-8 -*-
require 'zip'

class Objects::TowersController < ApplicationController
  def index
    rel = Objects::Tower
    @search = search_params
    if @search.present?
      rel = rel.where(name: @search[:name].mongonize) if @search[:name].present?
      rel = rel.where(region_id: @search[:region]) if @search[:region].present?
      rel = rel.where(kmlid: @search[:kmlid].mongonize) if @search[:kmlid].present?
      rel = rel.where(linename: @search[:linename].mongonize) if @search[:linename].present?
    end
    respond_to do |format|
      format.html { @title='ანძები' ; @towers=rel.asc(:kmlid).paginate(per_page:10, page: params[:page]) }
      format.xlsx{ @towers= rel.asc(:kmlid) }
    end
  end

  def upload
    @title='ფაილის ატვირთვა'
    if request.post?
      f = params[:data].original_filename
      case File.extname(f).downcase
      when '.kmz' then upload_kmz(params[:data].tempfile)
      when '.kml' then upload_kml(params[:data].tempfile)
      when '.xlsx' then upload_xlsx(params[:data].tempfile)
      else raise 'არასწორი ფორმატი' end
      redirect_to objects_towers_url, notice: 'მონაცემები ატვირთულია'
    end
  end

  def upload_photo
    @title = 'გამოსახულების ატვირთვა'
    @tower = Objects::Tower.find(params[:id])
    if request.post?
      file = params[:data].tempfile
      filename = params[:data].original_filename
      @tower.generate_images_from_file(file.path, filename)
      redirect_to objects_tower_url(id: @tower.id), notice: 'გამოსახულედა დამატებულია'
    end
  end

  def show
    @title='ანძის თვისებები'
    @tower=Objects::Tower.find(params[:id])
  end

  protected
  def nav
    @nav=super
    @nav['ანძები']=objects_towers_url
    if @tower
      @nav[@tower.name] = objects_tower_url(id: @tower.id) unless ['show'].include?(action_name)
    end
    @nav[@title]=nil unless ['index'].include?(action_name)
  end

  private

  def upload_kmz(file)
    Zip::File.open file do |zip_file|
      zip_file.each do |entry|
        upload_kml(entry) if 'kml'==entry.name[-3..-1]
      end
    end
  end

  def upload_kml(file)
    kml=file.get_input_stream.read
    Objects::Tower.from_kml(kml)
  end

  def upload_xlsx(file)
    sheet=Roo::Spreadsheet.open(file.path, extension: 'xlsx')
    (2..sheet.last_row).each do |row|
      id=sheet.cell('A',row) ; name=sheet.excelx_value('C',row).to_s ; category=sheet.cell('D', row)
      regionname=sheet.cell('E',row).to_s
      lat=sheet.cell('F',row).to_f; lng=sheet.cell('G',row).to_f
      description=sheet.cell('H',row)
      region=Region.where(name:regionname).first
      region=Region.create(name:regionname) unless region.present?
      tower=Objects::Tower.find(id)
      tower.name=name ; tower.region=region ; tower.category=category
      tower.lat=lat ; tower.lng=lng; tower.description=description
      tower.save
    end
  end
end
