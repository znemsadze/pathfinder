# -*- encoding : utf-8 -*-
module Forms::Sys::UserHelper
  def sys_user_form(user, opts={})
    title=user.new_record? ? t('models.sys_user._actions.new_user') : t('models.sys_user._actions.edit_user')
    icon=user.new_record? ? '/icons/user--plus.png' : '/icons/user--pencil.png'
    forma_for user, title:title, collapsible:true, icon: icon do |f|
      f.text_field 'username', required:true, autofocus:true
      f.password_field 'password', required:user.new_record?
      f.text_field 'first_name', required:true
      f.text_field 'last_name', required:true
      f.text_field 'mobile', required:true
      f.submit t('models.general._actions.save')
    end
  end
end
