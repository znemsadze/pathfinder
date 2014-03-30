# -*- encoding : utf-8 -*-
Pathfinder::Application.routes.draw do
  scope controller: 'site' do
    get '/', action: 'index', as: 'home'
  end

  root 'site#index'
end
