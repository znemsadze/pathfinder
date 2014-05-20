# -*- encoding : utf-8 -*-
require 'zip'

class Objects::LinesController < ApplicationController
  def index
    @title='ხაზები'
    @towers=Objects::Line.asc(:kmlid).paginate(per_page:10, page: params[:page])
  end

  def upload
    @title='ხაზების ატვირთვა'
    if request.post?
      Zip::File.open params[:data].tempfile do |zip_file|
        zip_file.each do |entry|
          if 'kml'==entry.name[-3..-1]
            kml=entry.get_input_stream.read
            Objects::Line.from_kml(kml)
          end
        end
      end
      redirect_to objects_towers_url, notice: 'მონაცემები ატვირთულია'
    end
  end

  def show
    @title='ხაზის თვისებები'
    @tower=Objects::Line.find(params[:id])
  end

  protected
  def nav
    @nav=super
    @nav['ხაზები']=objects_lines_url
    @nav[@title]=nil unless ['index'].include?(action_name)
  end
end
