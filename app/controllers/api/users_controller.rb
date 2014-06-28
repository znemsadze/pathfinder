# -*- encoding : utf-8 -*-
class Api::UsersController < ApiController
  def login
    @user=Sys::User.authenticate(params[:username], params[:password])
    unless @user and @user.active
      render json: {error: 'არასწორი მომხამრებლი ან პაროლი'}
    end
  end
end