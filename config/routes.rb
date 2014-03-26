ShpostStorage::Application.routes.draw do

  resources :shelves

  resources :purchasedetails

  resources :purchases

  resources :stocks

  resources :purchases

  resources :areas

  resources :businesses

  resources :stock_logs, only: [:index, :show]

  resources :commodities

  resources :goodstypes

  resources :suppliers
  
  resources :specifications

  resources :user_logs, only: [:index, :show]

  root 'welcome#index'

  devise_for :users, controllers: { sessions: "users/sessions" }

  resources :users
  
  resources :units
 
  resources :units do
    resources :storages do
      member do
          get 'change'
      end
    end
  end

  resources :units do
     resources :users, :controller => 'unit_users'
  end

  resources :users do
     resources :roles, only: [:index, :new, :create, :show, :destroy]
  end

  resources :storages do
     resources :roles, :controller => 'storage_roles', only: [:index, :new, :create, :show, :destroy]
  end

  resources :commoditys do
     resources :specifications
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
