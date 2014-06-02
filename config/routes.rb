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

  scope '/regions', controller: 'regions' do
    get '/', action: 'index', as: 'regions'
    get '/show/:id', action: 'show', as: 'region'
    match '/new', action: 'new', as: 'new_region', via: [:get, :post]
    match '/edit/:id', action: 'edit', as: 'edit_region', via: [:get, :post]
    delete '/delete/:id', action: 'delete', as: 'delete_region'
  end

  namespace 'objects' do
    scope '/towers', controller: 'towers' do
      get '/', action: 'index', as: 'towers'
      get '/show/:id', action: 'show', as: 'tower'
      match '/upload', action: 'upload', via: ['get','post'], as: 'upload_towers'
    end
    scope '/offices', controller: 'offices' do
      get '/', action: 'index', as: 'offices'
      get '/show/:id', action: 'show', as: 'office'
      match '/upload', action: 'upload', via: ['get', 'post'], as: 'upload_offices'
    end
    scope '/substations', controller: 'substations' do
      get '/', action: 'index', as: 'substations'
      get '/show/:id', action: 'show', as: 'substation'
      match '/upload', action: 'upload', via: ['get', 'post'], as: 'upload_substations'
    end
    scope '/lines', controller: 'lines' do
      get '/', action: 'index', as: 'lines'
      get '/show/:id', action: 'show', as: 'line'
      match '/upload', action: 'upload', via: ['get','post'], as: 'upload_lines'
    end
    scope '/maps', controller: 'maps' do
      get '/editor', action: 'editor', as: 'map_editor'
    end
    scope '/path' do
      scope '/lines', controller: 'path_lines' do
        get '/', action: 'index', as: 'path_lines'
        get '/show/:id', action: 'show', as: 'path_line'
      end
      scope '/types', controller: 'path_types' do
        get '/', action: 'index', as: 'path_types'
        get '/show/:id', action: 'show', as: 'path_type'
        match '/new', action: 'new', as: 'new_path_type', via: ['get','post']
        match '/edit/:id', action: 'edit', as: 'edit_path_type', via: ['get', 'post']
        delete '/delete/:id', action: 'delete', as: 'delete_path_type'
        post '/up/:id', action: 'up', as: 'up_path_type'
        post '/down/:id', action: 'down', as: 'down_path_type'
      end
      scope '/surfaces', controller: 'path_surfaces' do
        get '/', action: 'index', as: 'path_surfaces'
        get '/show/:id', action: 'show', as: 'path_surface'
        match '/new', action: 'new', as: 'new_path_surface', via: ['get','post']
        match '/edit/:id', action: 'edit', as: 'edit_path_surface', via: ['get', 'post']
        delete '/delete/:id', action: 'delete', as: 'delete_path_surface'
        post '/up/:id', action: 'up', as: 'up_path_surface'
        post '/down/:id', action: 'down', as: 'down_path_surface'
      end
      scope '/details', controller: 'path_details' do
        get '/', action: 'index', as: 'path_details'
        get '/show/:id', action: 'show', as: 'path_detail'
        match '/new', action: 'new', as: 'new_path_detail', via: ['get','post']
        match '/edit/:id', action: 'edit', as: 'edit_path_detail', via: ['get', 'post']
        delete '/delete/:id', action: 'delete', as: 'delete_path_detail'
        post '/up/:id', action: 'up', as: 'up_path_detail'
        post '/down/:id', action: 'down', as: 'down_path_detail'
      end
    end
  end

  namespace 'api' do
    scope '/objects', controller: 'objects' do
      get '/', action: 'index'
    end
    scope '/paths', controller: 'paths' do
      get '/show', action: 'show'
      post '/new',  action: 'new'
      post '/edit', action: 'edit'
      post '/delete', action: 'delete'
    end
    scope '/lines', controller: 'lines' do
      get '/show', action: 'show'
      post '/new',  action: 'new'
      post '/edit', action: 'edit'
      post '/delete', action: 'delete'
    end
    scope 'towers', controller: 'towers' do
      get '/show', action: 'show'
      post '/new',  action: 'new'
      post '/edit', action: 'edit'
      post '/delete', action: 'delete'
    end
  end

  root 'site#index'
end
