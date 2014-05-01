require 'test_helper'

class Geo::PathTest < ActiveSupport::TestCase
  def clear_db
    make_clear_state
    assert_equal 0, Geo::Path.count
    assert_equal 0, Geo::Point.count
  end

  test 'create path with single point' do
    clear_db
    path=Geo::Path.new_path([[1,1]])
    assert_equal 0, Geo::Path.count
    assert_equal 0, Geo::Point.count
  end

  test 'simple path creation' do
    clear_db

    path=Geo::Path.new_path([[1,1],[2,2]])
    assert_equal 1, Geo::Path.count
    assert_equal 2, Geo::Point.count
    assert_equal Geo::Point.all.map{|x|x.id}, path.point_ids
    assert_equal Geo::Path.first, path
    assert_equal 2, path.points.count
    assert_equal Geo::Point.all.to_a, path.points.all.to_a
  end

  def join_path_testing(p1,p2,result)
    clear_db

    path1=Geo::Path.new_path(p1)
    path2=Geo::Path.new_path(p2)

    assert_equal 2, Geo::Path.count
    assert_equal (p1+p2).uniq.size, Geo::Point.count
    assert_equal p1.size, path1.point_ids.count
    assert_equal p2.size, path2.point_ids.count

    Geo::Path.join(path1,path2)

    all_paths=Geo::Path.all
    assert_equal result.size, all_paths.size
    result.each_with_index do |result_path, index|
      path=all_paths[index]
      points=path.point_ids.map{|x| p=Geo::Point.find(x) ; [p.lat,p.lng]}
      assert_equal points.size, result_path.size
      assert_equal result_path, points
    end
  end

  test 'path joins' do
    p1=[1,1] ; p2=[2,1] ; p3=[3,1] ; p4=[4,1]

    # Correct joins

    # p1,p2 + p1,p3 -> p1,p2,p3
    join_path_testing([p1,p2], [p2,p3], [[p1,p2,p3]])
    # p1,p2 + p3,p2 -> p1,p2,p3
    join_path_testing([p1,p2], [p3,p2], [[p1,p2,p3]])
    # p2,p1 + p3,p2 -> p1,p2,p3
    join_path_testing([p2,p1], [p3,p2], [[p1,p2,p3]])

    # p1,p2,p3 + p2,p3,p4 -> p1,p2,p3,p4
    join_path_testing([p1,p2,p3], [p2,p3,p4], [[p1,p2,p3,p4]])
    # p2,p3,p4 + p1,p2,p3 -> p4,p3,p2,p1
    join_path_testing([p2,p3,p4], [p1,p2,p3], [[p4,p3,p2,p1]])

    # p1,p2,p3,p4 + p2,p3 -> p1,p2,p3,p4
    join_path_testing([p1,p2,p3,p4], [p2,p3], [[p1,p2,p3,p4]])
    # p1,p2,p3,p4 + p2,p3,p4 -> p1,p2,p3,p4
    join_path_testing([p1,p2,p3,p4], [p2,p3,p4], [[p1,p2,p3,p4]])
    # p1,p2,p3,p4 + p1,p2,p3,p4 -> p1,p2,p3,p4
    join_path_testing([p1,p2,p3,p4], [p1,p2,p3,p4], [[p1,p2,p3,p4]])

    # Incorrect joins

    # p1,p2,p3 + p2,p3,p1 -> same
    join_path_testing([p1,p2,p3], [p2,p3,p1], [[p1,p2,p3],[p2,p3,p1]])
    # p1,p2,p3,p4 + p1,p4 -> same
    join_path_testing([p1,p2,p3,p4], [p1,p4], [[p1,p2,p3,p4],[p1,p4]])
    # p1,p2,p3,p4 + p4,p1 -> same
    join_path_testing([p1,p2,p3,p4], [p4,p1], [[p1,p2,p3,p4],[p4,p1]])
  end
end
