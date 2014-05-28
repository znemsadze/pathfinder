# -*- encoding : utf-8 -*-
require 'zip'
require 'roo'

class Objects::LinesController < ApplicationController
  def index
    respond_to do |format|
      format.html { @title='ხაზები'; @lines=Objects::Line.asc(:kmlid).paginate(per_page:10, page: params[:page]) }
      format.xlsx { @lines=Objects::Line.asc(:kmlid) }
    end
  end

  def upload
    @title='ფაილის ატვირთვა'
    if request.post?
      f=params[:data].original_filename
      case File.extname(f).downcase
      when '.kmz' then upload_kmz(params[:data].tempfile)
      when '.kml' then upload_kml(params[:data].tempfile)
      when '.xlsx' then upload_xlsx(params[:data].tempfile)
      else raise 'არასწორი ფორმატი' end
      redirect_to objects_lines_url, notice: 'მონაცემები ატვირთულია'
    end
  end

  def show
    @title='ხაზის თვისებები'
    @line=Objects::Line.find(params[:id])
  end

  protected
  def nav
    @nav=super
    @nav['ხაზები']=objects_lines_url
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
    Objects::Line.from_kml(kml)
  end

  def upload_xlsx(file)
    sheet=Roo::Spreadsheet.open(file.path, extension: 'xlsx')
    (2..sheet.last_row).each do |row|
      id=sheet.cell('A',row) ; name=sheet.cell('C',row) ; regionname=sheet.cell('D',row)
      region=Region.where(name:regionname).first
      region=Region.create(name:regionname) unless region.present?
      line=Objects::Line.find(id)
      line.name=name ; line.region=region ; line.save
    end
  end
end
