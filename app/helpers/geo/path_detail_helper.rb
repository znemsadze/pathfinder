# -*- encoding : utf-8 -*-
module Geo::PathDetailHelper
  def pathsurface_collection; h = {} ; Geo::PathSurface.asc(:type_id,:order_by).each{|x| h["#{x.type.name} ==> #{x.name}"] = x.id }; h end

  def pathdetail_form(detail,opts={})
    title=detail.new_record? ? 'ახალი დეტალი' : 'დეტალის შეცვლა'
    icon='/icons/magnifier.png'
    cancel_url=detail.new_record? ? geo_path_details_url : geo_path_detail_url(id: detail.id)
    forma_for detail, title: title, collapsible: true, icon: icon do |f|
      f.combo_field 'surface_id', collection: pathsurface_collection, empty: false, required: true, i18n: 'surface', readonly: (not detail.new_record?)
      f.text_field 'name', required: true, autofocus: true
      f.submit 'შენახვა'
      f.cancel_button cancel_url
    end
  end

  # def pathsurface_view(surface)
  #   view_for surface, title: 'სახეობის თვისება', icon: '/icons/car.png', collapsible: true do |f|
  #     f.edit_action geo_edit_path_surface_url(id:surface.id)
  #     f.delete_action geo_delete_path_surface_url(id:surface.id)
  #     f.tab title: 'ძირითადი', icon: '/icons/car.png' do |f|
  #       f.complex_field required: true, i18n: 'order_by' do |c|
  #         c.text_field 'type.name', after: '&mdash;'.html_safe, url: geo_path_type_url(id:surface.type_id)
  #         c.text_field 'order_by', tag: 'strong'
  #       end
  #       f.text_field 'name', required: true
  #     end
  #     f.tab title: 'სისტემური', icon: '/icons/traffic-cone.png' do |f|
  #       f.timestamps
  #       f.userstamps
  #     end
  #   end
  # end
end
