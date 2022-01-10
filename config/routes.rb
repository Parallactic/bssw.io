# frozen_string_literal: true

Rails.application.routes.draw do
  resources :features
  root 'pages#show', id: 'homepage'

  get '/robots.txt' => 'application#robots'

  get '/resources/:id', to: redirect('/items/%{id}/')
  get '/resources.rss', to: redirect('/items.rss')


  match '/items/contributors', to: 'resources#authors', via: :get
  get '/items/authors', to: redirect('/items/contributors')
  
  resources :site_items,
            only: %i[index show],
            controller: 'resources', path: 'items' do
    collection do
      get 'search'
    end
  end

  match '/contact', to: 'contacts#new', via: :get
  match '/contribute',
        to: 'pages#show',
        defaults: {
          id: 'what-to-contribute-content-for-better-scientific-software'
        },
        via: :get

  resources :fellows, only: %i[index show]
  resources 'contacts', only: %i[new create]
  resources 'contributes', only: %i[new create]
  resources :events, only: %i[index show]
  resources :blog_posts, only: %i[index show]
  resources :what_is, only: [:show], controller: 'resources'
  resources :how_tos, only: [:show], controller: 'resources'
  resources :pages, only: [:show]
  resources :communities, only: [:show]
  resources :categories, only: [:show]
  resources :rebuilds, only: [:index] do
    collection do
      post 'import'
    end
    member do
      post 'make_displayed'
    end
  end

  match '/psip', to: 'resources#show',
                 defaults: {
                   id: 'productivity-and-sustainability-improvement-planning-psip'
                 },
                 via: :get

  match '/fellowship', to: 'pages#show',
                       defaults: { id: 'bssw-fellowship-program' }, via: :get
  match '/FELLOWSHIP', to: 'pages#show',
                       defaults: { id: 'bssw-fellowship-program' }, via: :get

  match '/blog_posts/working-remotely-the-exascale-computing-project-ecp-panel-series-tips',
        to: 'resources#show',
        defaults: { id: 'tips-for-producing-online-panel-discussions' },
        via: :get

  match '/rebuild/search', to: 'rebuilds#search', via: :get

  match '/announcements/close', to: 'announcements#close', via: :post

  get '*path', to: 'application#not_found'
end
