class Api::GeoController < ApiController
  def new_path
    puts params
    render text:'ok'
  end
end