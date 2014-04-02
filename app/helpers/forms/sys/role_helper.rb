# -*- encoding : utf-8 -*-
module Forms::Sys::RoleHelper
  def sys_role_form(role,opts={})
    title=role.new_record? ? t('models.sys_role._actions.new_role') : t('models.sys_role._actions.edit_role')
    icon=role.new_record? ? '/icons/plus.png' : '/icons/pencil.png'
    cancel_url=role.new_record? ? admin_roles_url : admin_role_url(id:role.id)
    forma_for role, title:title, collapsible:true, icon: icon do |f|
      f.text_field 'name', required:true, autofocus:true
      f.text_field 'description', width:500
      f.submit t('models.general._actions.save')
      f.cancel_button cancel_url
    end
  end

  def sys_role_view(role,opts={})
    title=t('models.sys_role._actions.role_properties')
    icon='/icons/mask.png'
    tab=case opts[:tab] when 'users' then 1 when 'sys' then 2 else 0 end
    view_for role, title:title, icon:icon, collapsible:true, selected_tab:tab do |f|
      f.edit_action admin_edit_role_url(id:role.id)
      f.delete_action admin_destroy_role_url(id:role.id)
      f.tab title: t('models.general.general_properties'), icon:icon do |f|
        f.text_field 'name', required:true
        f.text_field 'description'
      end
      users_opts={title:t('models.sys_role.users'), icon:'/icons/users.png'}
      f.tab users_opts do |f|
        f.table_field 'users', table:users_opts do |tbl|
          tbl.table do |t|
            t.text_field 'full_name'
          end
        end
      end
      f.tab title:t('models.general.system_properties'), icon:system_icon do |f|
        f.timestamps
        f.userstamps
      end
    end
  end
end
