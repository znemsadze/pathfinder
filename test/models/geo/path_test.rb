# -*- encoding : utf-8 -*-
require 'test_helper'

class Geo::PathTest < ActiveSupport::TestCase
  def clear_db
    make_clear_state
    assert_equal 0, Geo::Path.count
    assert_equal 0, Geo::Point.count
  end

  test 'simplest splitjoin' do
    clear_db
    p1=Geo::Point.create(lat: 1,lng: 1)
    p2=Geo::Point.create(lat: 1,lng: 2)
    p3=Geo::Point.create(lat: 1,lng: 3)
    p4=Geo::Point.create(lat: 1,lng: 4)
    path1=Geo::Path.new_path([p1,p2,p3])
    path2=Geo::Path.new_path([p2,p3,p4])
    assert_equal 2, Geo::Path.count
    assert_equal 4, Geo::Point.count
    path1.splitjoin
    assert_equal 4, path1.points.size
  end
end
