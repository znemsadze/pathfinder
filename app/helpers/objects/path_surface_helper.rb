# -*- encoding : utf-8 -*-
module Objects::PathSurfaceHelper
  def pathtype_collection; h = {} ; Objects::Path::Type.asc(:order_by).each{|x| h[x.name] = x.id }; h end

  def pathsurface_form(surface,opts={})
    title=surface.new_record? ? 'ახალი საფარი' : 'საფარის შეცვლა'
    icon='/icons/road.png'
    cancel_url=surface.new_record? ? objects_path_surfaces_url : objects_path_surface_url(id: surface.id)
    forma_for surface, title: title, collapsible: true, icon: icon do |f|
      f.combo_field 'type_id', collection: pathtype_collection, empty: false, required: true, i18n: 'type', readonly: (not surface.new_record?)
      f.text_field 'name', required: true, autofocus: true
      f.submit 'შენახვა'
      f.cancel_button cancel_url
    end
  end

  def pathsurface_view(surface,opts={})
    idx=case opts[:tab] when 'sys' then 2 when 'details' then 1 else 0 end
    view_for surface, title: 'სახეობის თვისება', icon: '/icons/car.png', collapsible: true, selected_tab: idx do |f|
      f.edit_action objects_edit_path_surface_url(id:surface.id)
      f.delete_action objects_delete_path_surface_url(id:surface.id)
      f.tab title: 'ძირითადი', icon: '/icons/car.png' do |f|
        f.text_field 'order_by', tag: 'strong', required: true
        f.text_field 'type.name', required:true, i18n:'type', url: objects_path_type_url(id:surface.type_id)
        f.text_field 'name', required: true
      end
      f.tab title: "დეტალები &mdash; <strong>#{surface.details.count}</strong>".html_safe, icon: '/icons/magnifier.png' do |f|
        f.table_field 'details', table: {title: 'გზის საფარის დეტალები', icon: '/icons/magnifier.png'} do |f|
          f.table do |t|
            t.title_action objects_new_path_detail_url(surface_id: surface.id), label:'დეტალის დამატება', icon: '/icons/magnifier--plus.png'
            t.text_field 'order_by', tag: 'strong'
            t.text_field 'name', url: ->(x){objects_path_detail_url(id:x.id)}
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
