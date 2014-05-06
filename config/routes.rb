# -*- encoding : utf-8 -*-
Pathfinder::Application.routes.draw do
  scope controller: 'site' do
    get '/', action: 'index', as: 'home'
    match '/login', action: 'login', as: 'login', via: ['get','post']
    get '/logout', action: 'logout'
  end

  namespace 'account' do
    scope '/profile', controller: 'profile' do
      get '/', action: 'index', as: 'profile'
      match '/edit', action: 'edit', as: 'edit_profile', via:[:get,:post]
      match '/change_password', action: 'change_password', as: 'change_password', via:[:get,:post]
    end
  end

  namespace 'admin' do
    scope '/users', controller: 'users' do
      get '/', action: 'index', as: 'users'
      get '/show/:id', action: 'show', as: 'user'
      match '/new', action: 'new', as: 'new_user', via: ['get','post']
      match '/edit/:id', action: 'edit', as: 'edit_user', via: ['get','post']
      delete '/delete/:id', action: 'destroy', as: 'destroy_user'
      match '/add_role/:id', action:'add_role', as:'user_add_role', via:['get','post']
      delete '/remove_role/:id/:role_id', action:'remove_role', as:'user_remove_role'
    end
    scope '/roles', controller: 'roles' do
      get '/', action: 'index', as:'roles'
      get '/show/:id', action:'show', as:'role'
      match '/new', action:'new', as:'new_role', via:['get','post']
      match '/edit/:id', action:'edit', as:'edit_role', via:['get','post']
      delete '/delete/:id', action:'destroy', as:'destroy_role'
      match '/add_user/:id', action:'add_user', as:'role_add_user', via:['get','post']
      delete '/remove_user/:id/:user_id', action:'remove_user', as:'role_remove_user'
    end
  end

  namespace 'geo' do
    scope '/map', controller: 'map' do
      get '/', action: 'index', as: 'map'
    end
  end

  namespace 'api' do
    scope '/geo', controller: 'geo' do
      post '/new_path',  action: 'new_path',  as: 'new_path'
      post '/edit_path', action: 'edit_path', as: 'edit_path'
      post '/delete_path', action: 'delete_path', as: 'delete_path'
    end
  end

  root 'site#index'
end
