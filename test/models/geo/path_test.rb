require 'test_helper'

class Geo::PathTest < ActiveSupport::TestCase
  test 'the truth' do
    make_clear_state

    path1=Geo::Path.create
    path2=Geo::Path.create
    assert_equal 2, Geo::Path.count

    p1=Geo::Point.create(lat: 40, lng: 40)
    p2=Geo::Point.create(lat: 45, lng: 45)
    p3=Geo::Point.create(lat: 40, lng: 50)
    p4=Geo::Point.create(lat: 45, lng: 30)
    assert_equal 4, Geo::Point.count

    path1.points<<p1
    path1.points<<p2
    path1.points<<p3

    path2.points<<p2
    path2.points<<p4

    path1.reload

    assert_equal 3, path1.points.count
    assert_equal 1, p1.paths.count
    assert_equal 2, p2.paths.count
    assert_equal 1, p3.paths.count

    assert_equal 2, path2.points.count
    assert_equal 2, p2.paths.count
    assert_equal 1, p4.paths.count

    path1.split_intersections
    assert_equal 3, Geo::Path.count

    p1.reload ; p2.reload ; p3.reload ; p4.reload

    assert_equal 1, p1.paths.count
    assert_equal 3, p2.paths.count
    assert_equal 1, p3.paths.count
    assert_equal 1, p4.paths.count
  end
end
