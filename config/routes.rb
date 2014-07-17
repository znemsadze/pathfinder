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
      match '/add_region/:id', action: 'add_region', as: 'user_add_region', via: ['get', 'post']
      delete '/remove_region/:id', action: 'remove_region', as: 'user_remove_region'
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
      match 'clear_cache', action: 'clear_cache', as: 'clear_cache', via: ['get', 'post']
      match 'generate_images', action: 'generate_images', as: 'generate_images', via: ['get', 'post']
    end
    scope '/path' do
      scope '/lines', controller: 'path_lines' do
        get '/', action: 'index', as: 'path_lines'
        get '/show/:id', action: 'show', as: 'path_line'
        match '/upload', action: 'upload', via: ['get','post'], as: 'upload_path_lines'
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

  namespace 'tasks' do
    scope '/', controller: 'base' do
      get '/open', action: 'open', as: 'open'
      get '/all', action: 'all', as: 'all'
      get '/show/:id', action: 'show', as: 'task'
      match '/edit/:id', action: 'edit', as: 'edit_task', via: ['get', 'post']
      delete '/delete/:id', action: 'destroy', as: 'delete_task'
      post '/begin/:id', action: 'begin_task', as: 'begin_task'
      post '/cancel/:id', action: 'cancel_task', as: 'cancel_task'
      post '/complete/:id', action: 'complete_task', as: 'complete_task'
    end
    scope 'tracking', controller: 'tracking' do
      get '/', action: 'index', as: 'tracking'
      get '/user/:id', action: 'user', as: 'tracking_user'
      get '/track/:id', action: 'track', as: 'tracking_track'
    end
  end

  namespace 'api' do
    scope '/users', controller: 'users' do
      get '/', action: 'index'
      post '/login', action: 'login'
      post '/track_point', action: 'track_point'
    end
    scope '/objects', controller: 'objects' do
      get '/', action: 'index'
      get '/lines', action: 'lines'
      get '/pathlines', action: 'pathlines'
      get '/offices', action: 'offices'
      get '/substations', action: 'substations'
      get '/towers', action: 'towers'
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
    scope 'offices', controller: 'offices' do
      get '/show', action: 'show'
      post '/new',  action: 'new'
      post '/edit', action: 'edit'
      post '/delete', action: 'delete'
    end
    scope 'substations', controller: 'substations' do
      get '/show', action: 'show'
      post '/new',  action: 'new'
      post '/edit', action: 'edit'
      post '/delete', action: 'delete'
    end
    scope 'shortestpath', controller: 'shortestpath' do
      get '/', action: 'index'
    end
    scope 'tasks', controller: 'tasks' do
      match '/', action: 'index', via: ['get', 'post']
      post '/new', action: 'new'
      post '/begin_task', action: 'begin_task'
      post '/complete_task', action: 'complete_task'
      post '/cancel_task', action: 'cancel_task'
    end
  end

  root 'site#index'
end
