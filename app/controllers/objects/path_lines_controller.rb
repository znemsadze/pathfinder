# -*- encoding : utf-8 -*-
class Objects::PathLinesController < ApplicationController
  def index
    @title = 'მარშუტები'
    rel = Objects::Path::Line.asc(:name)
    respond_to do |format|
      format.html { @lines = rel.paginate(per_page: 10, page: params[:page]) }
      format.xlsx { @lines = rel }
    end
  end

  def show
    @title='მარშუტის თვისებები'
    @line=Objects::Path::Line.find(params[:id])
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
      redirect_to objects_upload_path_lines_url(status: 'ok')
    end
  end

  protected
  def nav
    @nav=super
    @nav['მარშუტები']=objects_path_lines_url
    if @line || ['upload'].include?(action_name)
      @nav[@line.name]=objects_path_line_url(id:@line.id) if 'edit'==action_name
      @nav[@title]=nil
    end
  end

  def upload_kmz(file)
    Zip::File.open file do |zip_file|
      zip_file.each do |entry|
        if entry.name == 'doc.kml'
          tempfile = Tempfile.new(entry.name)
          zip_file.extract(entry, tempfile){ true }
          upload_kml(tempfile)
        end
      end
    end
  end

  def upload_kml(file); KMLConverter.perform_async('Objects::Path::Line', file.path.to_s) end
  def upload_xlsx(file); XLSConverter.perform_async('Objects::Path::Line', file.path.to_s) end
end
