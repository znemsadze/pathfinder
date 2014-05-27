# -*- encoding : utf-8 -*-
require 'test_helper'

class Objects::LineTest < ActiveSupport::TestCase
  def clear_db; make_clear_state end
  def kmlpath(file); "#{Rails.root}/test/data/#{file}" end

  test 'parsing KML file' do
    clear_db
    assert_equal 0, Objects::Line.count
    xml=File.read(kmlpath('lines.kml'))
    Objects::Line.from_kml xml
    assert_equal 26, Objects::Line.count
    l1=Objects::Line.first
    assert_equal 39, l1.points.count

    Objects::Line.from_kml xml
    assert_equal 26, Objects::Line.count
    assert_equal 39, l1.points.count

    l1=Objects::Line.first
    refute_nil l1.region
    assert_equal 'იმერეთი', l1.region.name
  end
end
