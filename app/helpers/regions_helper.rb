# -*- encoding : utf-8 -*-
module RegionsHelper
  def region_form(region,opts={})
    title=region.new_record? ? 'ახალი რეგიონი' : 'რეგიონის შეცვლა'
    icon=region.new_record? ? '/icons/region--plus.png' : '/icons/region--pencil.png'
    cancel_url=region.new_record? ? regions_url : region_url(id: region.id)
    forma_for region, title: title, collapsible: true, icon: icon do |f|
      f.text_field 'name', required: true, autofocus: true
      f.text_field 'description'
      f.submit 'შენახვა'
      f.cancel_button cancel_url
    end
  end

  def region_view(region,opts={})
    title='რეგიონის თვისებები'; icon='/icons/region.png'
    idx=case opts[:tab] when 'lines' then 1 when 'sys' then 2 else 0 end
    view_for region, title: title, collapsible: true, icon: icon, selected_tab: idx do |v|
      v.edit_action edit_region_url(id:region.id)
      v.delete_action delete_region_url(id:region.id)
      v.tab title: 'ზოგადი', icon:icon do |v|
        v.text_field 'name', required: true
        v.text_field 'description'
      end
      v.tab title: "ხაზები &mdash; <strong>#{region.lines.count}</strong>".html_safe, icon: '/icons/line.png' do |v|
        v.table_field 'lines', table: {title:'ხაზები', icon: '/icons/line.png'} do |field|
          field.table do |t|
            t.text_field 'name', url: ->(x){objects_line_url(id:x.id)}
          end
        end
      end
      v.tab title: 'სისტემური',icon:'/icons/traffic-cone.png' do |v|
        v.timestamps
        v.userstamps
      end
    end
  end
end
