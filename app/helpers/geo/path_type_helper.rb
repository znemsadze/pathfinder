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
end
