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

    assert_equal 0, path1.ordered_points.count
    assert_equal 0, path2.ordered_points.count
    assert_equal 4, path3.ordered_points.count
  end

  #         5     path1: 4,1,2,3
  #        /      path2: 4,3
  #  4<-->3       path3: 3,5
  #  |    |       path4: 2,6
  #  1____2
  #       \
  #        6
  test 'cycle join and split' do
    make_clear_state

    p1=Geo::Point.create(lat: 5,lng: 5)
    p2=Geo::Point.create(lat:10,lng: 5)
    p3=Geo::Point.create(lat:10,lng:10)
    p4=Geo::Point.create(lat: 5,lng:10)
    p5=Geo::Point.create(lat:15,lng:15)
    p6=Geo::Point.create(lat:15,lng: 0)

    ps=[p1,p2,p3,p4,p5,p6]

    # path1[4,1,2,3] + path2[3,4] -> should not join!
    path1=Geo::Path.create ; path2=Geo::Path.create
    path1.points<<p4 ; path1.points<<p1 ; path1.points<<p2 ; path1.points<<p3
    path2.points<<p3 ; path2.points<<p4
    path2.split_intersections ; path2.join_continuations
    path1.reload ; path2.reload
    assert_equal 0, path1.ordered_points.count
    assert_equal 5, path2.ordered_points.count
    path2.reload

    assert_equal 4, path2.ordered_points.count
    assert_equal [p4,p1,p2,p3].map{|x|x.id.to_s}, path2.ordered_points.map{|x|x.id.to_s}
    assert_equal 2, Geo::Path.count

# puts '---------------------'
# Geo::Path.each do |path|
#   path.reload
#   path_idx=[path1,path2].index(path)
#   path_idx+=1 if path_idx
#   indecies=path.ordered_points.map{|x| ps.index(x)+1}.join(', ')
#   puts "#{path_idx||'*'}: #{indecies}"
# end
# puts '---------------------'

#     # path[4,3,2,1,4] + path3[3,5]
#     path3=Geo::Path.create
#     path3.points<<p3 ; path3.points<<p5
#     path3.split_intersections
#     path3.join_continuations


# puts '---------------------'
# Geo::Path.each do |path|
#   path.reload
#   path_idx=[path1,path2,path3].index(path)
#   path_idx+=1 if path_idx
#   indecies=path.ordered_points.map{|x| ps.index(x)+1}.join(', ')
#   puts "#{path_idx||'*'}: #{indecies}"
# end
# puts '---------------------'

#     all_paths.each{|x|x.reload} ; all_points.each{|x|x.reload}
#     assert_equal 0, path1.ordered_points.count

# puts ''
# puts Geo::Path.count
# puts all_points.map{|x|x.id.to_s}.join(' > ')

#     #assert_equal 4, path2.ordered_points.count
#     assert_equal 2, path3.ordered_points.count

# puts path2.ordered_points.map{|x|x.id.to_s}.join(' > ')


    # Geo::Path.destroy_empty
    # assert_equal 4, Geo::Path.count


    # path4.points<<p2 ; path4.points<<p6
    # path4.join_continuations
    # path1.reload ; path2.reload ; path3.reload ; path4.reload
    # assert_equal 0, path1.points.count


  end
end
