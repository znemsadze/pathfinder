require 'test_helper'

class Geo::PathTest < ActiveSupport::TestCase
  test 'path splitting' do
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

  test 'joining paths' do
    make_clear_state

    path1=Geo::Path.create
    path2=Geo::Path.create
    assert_equal 2, Geo::Path.count

    p1=Geo::Point.create(lat: 40, lng: 40)
    p2=Geo::Point.create(lat: 45, lng: 45)
    p3=Geo::Point.create(lat: 40, lng: 50)
    p4=Geo::Point.create(lat: 45, lng: 30)
    assert_equal 4, Geo::Point.count

    p1.paths<<path1
    p2.paths<<path1
    p2.paths<<path2
    p3.paths<<path2
    p4.paths<<path2

    p1.reload ; p2.reload ; p3.reload ; p4.reload

    path1.join_continuations
    path1.reload ; path2.reload

    assert_equal 4, path1.points.count
    assert_equal 0, path2.points.count
  end

  test 'complex join' do
    make_clear_state

    path1=Geo::Path.create
    path2=Geo::Path.create
    path3=Geo::Path.create

    p1=Geo::Point.create(lat: 40, lng: 40)
    p2=Geo::Point.create(lat: 50, lng: 40)
    p3=Geo::Point.create(lat: 40, lng: 30)
    p4=Geo::Point.create(lat: 50, lng: 30)

    # p1 ___ p2
    #        |
    # p3 ___ p4

    path1.points<<p1
    path1.points<<p2

    path2.points<<p3
    path2.points<<p4

    path3.points<<p2
    path3.points<<p4

    path3.join_continuations
    path1.reload ; path2.reload ; path3.reload

    assert_equal 0, path1.points.count
    assert_equal 0, path2.points.count
    assert_equal 4, path3.points.count
  end
end
