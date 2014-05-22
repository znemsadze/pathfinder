# -*- encoding : utf-8 -*-
module Objects::PathDetailHelper
  def pathsurface_collection; h = {} ; Objects::Path::Surface.asc(:type_id,:order_by).each{|x| h["#{x.type.name} ==> #{x.name}"] = x.id }; h end

  def pathdetail_form(detail,opts={})
    title=detail.new_record? ? 'ახალი დეტალი' : 'დეტალის შეცვლა'
    icon='/icons/magnifier.png'
    cancel_url=detail.new_record? ? objects_path_details_url : objects_path_detail_url(id: detail.id)
    forma_for detail, title: title, collapsible: true, icon: icon do |f|
      f.combo_field 'surface_id', collection: pathsurface_collection, empty: false, required: true, i18n: 'surface', readonly: (not detail.new_record?)
      f.text_field 'name', required: true, autofocus: true
      f.submit 'შენახვა'
      f.cancel_button cancel_url
    end
  end

  def pathdetail_view(detail)
    title="გზის დეტალი: #{detail.name}"
    view_for detail, title: title, icon: '/icons/magnifier.png', collapsible: true do |f|
      f.edit_action objects_edit_path_detail_url(id:detail.id)
      f.delete_action objects_delete_path_detail_url(id:detail.id)
      f.tab title: 'ძირითადი', icon: '/icons/magnifier.png' do |f|
        f.text_field 'order_by', tag: 'strong', required: true
        f.text_field 'surface.type.name', i18n: 'type', required: true, url: objects_path_type_url(id:detail.surface.type.id)
        f.text_field 'surface.name', i18n: 'surface', required: true, url: objects_path_surface_url(id:detail.surface_id)
        f.text_field 'name', required: true
      end
      f.tab title: 'სისტემური', icon: '/icons/traffic-cone.png' do |f|
        f.timestamps
        f.userstamps
      end
    end
  end
end
