# -*- encoding : utf-8 -*-
class Sys::Permission
  def self.has_permission?(user, controller, action)
    # if user and user.admin? then true # admin has all privileges
    # elsif Sys::Permission.count == 0 then true # no permissions defined yet
    # else
    #   permission = Sys::Permission.where(controller: controller, action: action).first
    #   if permission
    #     if permission.public_page then true # everyone has access to public page
    #     elsif user.blank? then false # authentication required for non-public pages
    #     elsif permission.admin_page then false # only admin has access to admin page
    #     else
    #       if permission.roles.empty? then true # no role required for this action
    #       else
    #         if (permission.roles & user.roles).any? then true # user roles has intersection with permission roles
    #         else false end # ... no intersection => no permission
    #       end
    #     end
    #   else
    #     false
    #   end
    # end
    true
  end
end
