# -*- encoding : utf-8 -*-
require 'test_helper'

class Geo::PathTest < ActiveSupport::TestCase
  def clear_db
    make_clear_state
    assert_equal 0, Geo::Path.count
    assert_equal 0, Geo::Point.count
  end

  
end
