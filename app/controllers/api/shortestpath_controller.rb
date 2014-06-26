# -*- encoding : utf-8 -*-
class Api::ShortestpathController < ApiController
  def index

    render text: params
  end
end
