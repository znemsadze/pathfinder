# -*- encoding : utf-8 -*-
module Geo::PathTypeHelper
  def pathtype_form(type,opts={})
    title=type.new_record? ? 'ახალი სახეობა' : 'სახეობის შეცვლა'
    icon='/icons/road.png'
    cancel_url=type.new_record? ? geo_path_types_url : geo_path_type_url(id: type.id)
    forma_for type, title: title, collapsible: true, icon: icon do |f|
      f.text_field 'name', required: true, autofocus: true
      f.submit 'შენახვა'
      f.cancel_button cancel_url
    end
  end

  def pathtype_view(type,opts={})
    idx=case opts[:tab] when 'sys' then 2 when 'surfaces' then 1 else 0 end
    view_for type, title: "გზის სახეობა: #{type.name}", icon: '/icons/road.png', collapsible: true, selected_tab: idx do |f|
      f.edit_action geo_edit_path_type_url(id:type.id)
      f.delete_action geo_delete_path_type_url(id:type.id)
      f.tab title: 'ძირითადი', icon: '/icons/road.png' do |f|
        f.text_field 'order_by', required: true, tag: 'strong'
        f.text_field 'name', required: true
      end
      f.tab title: "საფარი &mdash; <strong>#{type.surfaces.count}</strong>".html_safe, icon: '/icons/car.png' do |f|
        f.table_field 'surfaces', table:{ title: 'გზის საფარი', icon: '/icons/car.png'} do |fld|
          fld.table do |t|
            t.title_action geo_new_path_surface_url(type_id:type.id),label: 'ახალი საფარი', icon: '/icons/plus.png'
            t.text_field 'order_by', tag: 'strong'
            t.text_field 'name', url: ->(x){geo_path_surface_url(id:x.id)}
          end
        end
      end
      f.tab title: 'სისტემური', icon: '/icons/traffic-cone.png' do |f|
        f.timestamps
        f.userstamps
      end
    end
  end
end
