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

  namespace 'objects' do
    scope '/towers', controller: 'towers' do
      get '/', action: 'index', as: 'towers'
      get '/show/:id', action: 'show', as: 'tower'
      match '/upload', action: 'upload', via: ['get','post'], as: 'upload_towers'
    end
    scope '/lines', controller: 'lines' do
      get '/', action: 'index', as: 'lines'
      get '/show/:id', action: 'show', as: 'line'
      match '/upload', action: 'upload', via: ['get','post'], as: 'upload_lines'
    end
  end

  namespace 'geo' do
    scope '/map', controller: 'map' do
      get '/', action: 'index', as: 'map'
    end
    scope '/pathtype', controller: 'path_types' do
      get '/', action: 'index', as: 'path_types'
      get '/show/:id', action: 'show', as: 'path_type'
      match '/new', action: 'new', as: 'new_path_type', via: ['get','post']
      match '/edit/:id', action: 'edit', as: 'edit_path_type', via: ['get', 'post']
      delete '/delete/:id', action: 'delete', as: 'delete_path_type'
      post '/up/:id', action: 'up', as: 'up_path_type'
      post '/down/:id', action: 'down', as: 'down_path_type'
    end
    scope '/pathsurface', controller: 'path_surfaces' do
      get '/', action: 'index', as: 'path_surfaces'
      get '/show/:id', action: 'show', as: 'path_surface'
      match '/new', action: 'new', as: 'new_path_surface', via: ['get','post']
      match '/edit/:id', action: 'edit', as: 'edit_path_surface', via: ['get', 'post']
      delete '/delete/:id', action: 'delete', as: 'delete_path_surface'
      post '/up/:id', action: 'up', as: 'up_path_surface'
      post '/down/:id', action: 'down', as: 'down_path_surface'
    end
    scope '/pathdetail', controller: 'path_details' do
      get '/', action: 'index', as: 'path_details'
      get '/show/:id', action: 'show', as: 'path_detail'
      match '/new', action: 'new', as: 'new_path_detail', via: ['get','post']
      match '/edit/:id', action: 'edit', as: 'edit_path_detail', via: ['get', 'post']
      delete '/delete/:id', action: 'delete', as: 'delete_path_detail'
      post '/up/:id', action: 'up', as: 'up_path_detail'
      post '/down/:id', action: 'down', as: 'down_path_detail'
    end
  end

  namespace 'api' do
    scope '/geo', controller: 'geo' do
      get '/path', action: 'path', as: 'path'
      post '/new_path',  action: 'new_path',  as: 'new_path'
      post '/edit_path', action: 'edit_path', as: 'edit_path'
      post '/delete_path', action: 'delete_path', as: 'delete_path'
    end
    scope '/objects', controller: 'objects' do
      get '/all', action: 'all', as: 'all_objects'
    end
  end

  root 'site#index'
end
