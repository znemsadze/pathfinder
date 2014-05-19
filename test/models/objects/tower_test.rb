# -*- encoding : utf-8 -*-
require 'test_helper'

class Objects::TowerTest < ActiveSupport::TestCase
  def clear_db; make_clear_state end

  def kmlpath(file); "#{Rails.root}/test/data/#{file}" end

  test 'parsing KML file' do
    clear_db
    assert_equal 0, Objects::Tower.count

    xml=File.read(kmlpath('towers.kml'))
    Objects::Tower.from_kml xml
    assert_equal 194, Objects::Tower.count
    Objects::Tower.from_kml xml
    assert_equal 194, Objects::Tower.count
  end
end
