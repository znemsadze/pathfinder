# -*- encoding : utf-8 -*-
Pathfinder::Application.routes.draw do
  scope controller: 'site' do
    get '/', action: 'index', as: 'home'
    match '/login', action: 'login', as: 'login', via: ['get','post']
  end

  root 'site#index'
end
