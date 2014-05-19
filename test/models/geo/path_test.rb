# -*- encoding : utf-8 -*-
require 'test_helper'

# class Geo::PathTest < ActiveSupport::TestCase
#   def clear_db
#     make_clear_state
#     assert_equal 0, Geo::Path.count
#     assert_equal 0, Geo::Point.count
#   end

#   def splitjoin_testing(paths,results)
#     clear_db
#     paths.each {|path| Geo::Path.new_path(path)}
#     assert_equal paths.count, Geo::Path.count
#     assert_equal paths.flatten.uniq.size, Geo::Point.count
#     Geo::Path.first.splitjoin
#     paths=Geo::Path.all
#     assert_equal results.size, paths.size, 'compare path count with expected'
#     results.each_with_index do |result,i|
#       path=paths[i]
#       assert_equal result.size, path.point_ids.size, "@error: #{i}"
#       result.each_with_index do |corrdinates,j|
#         point=Geo::Point.find(path.point_ids[j])
#         assert_equal corrdinates, [point.lat,point.lng], "@error #{i}:#{j}"
#       end
#     end
#   end

#   test 'simplest splitjoin' do
#     p1=[1,1] ; p2=[1,2] ; p3=[1,3] ; p4=[1,4]
#     p5=[0,0] ; p6=[0,5]

#     # (p2,p1)+(p2,p3)-> (p1,p2,p3)
#     splitjoin_testing([[p2,p1],[p2,p3]],[[p3,p2,p1]])

#     # (p1,p2)+(p2,p3) -> (p1,p2,p3)
#     splitjoin_testing([[p1,p2],[p2,p3]],[[p1,p2,p3]])

#     # (p2,p3)+(p1,p2) -> (p1,p2,p3)
#     splitjoin_testing([[p2,p3],[p1,p2]],[[p1,p2,p3]])

#     # (p1,p2,p3) + (p2,p3,p4) -> (p1,p2,p3,p4)
#     splitjoin_testing([[p1,p2,p3],[p2,p3,p4]],[[p1,p2,p3,p4]])

#     # (p2,p3,p4) + (p1,p2,p3) -> (p1,p2,p3,p4)
#     splitjoin_testing([[p2,p3,p4],[p1,p2,p3]],[[p1,p2,p3,p4]])

#     # (p1,p2,p3) + (p2,p4) -> (p1,p2),(p2,p4),(p2,p3)
#     splitjoin_testing([[p1,p2,p3],[p2,p4]],[[p1,p2],[p2,p4],[p2,p3]])

#     # (p2,p4) + (p1,p2,p3) -> (p1,p2),(p2,p4),(p2,p3)
#     splitjoin_testing([[p2,p4],[p1,p2,p3]],[[p2,p4],[p1,p2],[p2,p3]])

#     # (p4,p3)+(p1,p2,p3) -> (p4,p3,p2,p1)
#     splitjoin_testing([[p4,p3],[p1,p2,p3]],[[p4,p3,p2,p1]])

#     # (p1,p2,p3,p4) + (p5,p2,p4,p6) -> (p1,p2),(p5,p2),(p2,p3),(p3,p4),(p3,p6)   
#     splitjoin_testing([[p1,p2,p3,p4],[p5,p2,p3,p6]],[[p1,p2],[p5,p2],[p2,p3],[p3,p4],[p3,p6]])

#     # (p1,p2,p3,p4) + (p1,p4) -> (p1,p2,p3,p4) + (p1,p4)
#     splitjoin_testing([[p1,p2,p3,p4],[p1,p4]],[[p1,p2,p3,p4],[p1,p4]])    
#   end
# end
