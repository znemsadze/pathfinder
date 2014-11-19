class Admin::HelpController < ApplicationController
  def index; @title = 'დახმარება' end

  protected
  def nav
    @nav=super
    @nav['დახმარება'] = admin_help_url
  end

  # def login_required; true end
  # def permission_required; not current_user.admin? end
end