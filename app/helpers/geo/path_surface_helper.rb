# -*- encoding : utf-8 -*-
module Geo::PathSurfaceHelper
  def pathtype_collection
    h = {} ; Geo::PathType.asc(:order_by).each{|x| h[x.name] = x.id }; h
  end

  def pathsurface_form(surface,opts={})
    title=surface.new_record? ? 'ახალი საფარი' : 'საფარის შეცვლა'
    icon='/icons/road.png'
    cancel_url=surface.new_record? ? geo_path_surfaces_url : geo_path_surface_url(id: surface.id)
    forma_for surface, title: title, collapsible: true, icon: icon do |f|
      f.combo_field 'type_id', collection: Geo::PathType.asc(:order_by), empty: false, required: true, i18n: 'type'
      f.text_field 'name', required: true, autofocus: true
      f.submit 'შენახვა'
      f.cancel_button cancel_url
    end
  end

  # def pathtype_view(type)
  #   view_for type, title: 'სახეობის თვისება', icon: '/icons/road.png', collapsible: true do |f|
  #     f.edit_action geo_edit_path_type_url(id:type.id)
  #     f.delete_action geo_delete_path_type_url(id:type.id)
  #     f.tab title: 'ძირითადი', icon: '/icons/road.png' do |f|
  #       f.text_field 'order_by', required: true, tag: 'strong'
  #       f.text_field 'name', required: true
  #     end
  #     f.tab title: 'სისტემური', icon: '/icons/traffic-cone.png' do |f|
  #       f.timestamps
  #       f.userstamps
  #     end
  #   end
  # end
end
