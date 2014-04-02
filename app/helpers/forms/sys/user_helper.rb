# -*- encoding : utf-8 -*-
module Forms::Sys::UserHelper
  def sys_user_form(user,opts={})
    title=user.new_record? ? t('models.sys_user._actions.new_user') : t('models.sys_user._actions.edit_user')
    icon=user.new_record? ? '/icons/user--plus.png' : '/icons/user--pencil.png'
    cancel_url=user.new_record? ? admin_users_url : admin_user_url(id:user.id)
    forma_for user, title:title, collapsible:true, icon: icon do |f|
      f.text_field 'username', required:true, autofocus:true
      f.password_field 'password', required:user.new_record?
      f.text_field 'first_name', required:true
      f.text_field 'last_name', required:true
      f.text_field 'mobile', required:true
      f.submit t('models.general._actions.save')
      f.cancel_button cancel_url
    end
  end

  def sys_user_view(user,opts={})
    title=t('models.sys_user._actions.user_properties')
    icon='/icons/user.png'
    view_for user, title:title, icon:icon, collapsible:true do |f|
      f.edit_action admin_edit_user_url(id:user.id)
      f.delete_action admin_destroy_user_url(id:user.id)
      f.tab title: t('models.general.general_properties'), icon:icon do |f|
        f.text_field 'username', required:true, tag:'code'
        f.text_field 'full_name', required:true
        f.text_field 'formatted_mobile', required:true, tag:'code', i18n:'mobile'
        f.boolean_field 'active', required:true
      end
      f.tab title: t('models.general.system_properties'), icon:system_icon do |f|
        f.timestamps
        f.userstamps
      end
    end
  end
end
