module Sys::UserHelper
  def sys_admin?
    if Sys::User.count==0 then true
    elsif curr_user and curr_user.admin? then true
    else false end
  end
end
