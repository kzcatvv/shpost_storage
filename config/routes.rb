ShpostStorage::Application.routes.draw do


  resources :contacts do
    get 'relation', on: :collection
  end

  resources :orders do
     collection do
        get 'findprint'
        get 'stockout'
        get 'ordercheck'
        get 'nextbatch'
        get 'packout'
        get 'findorderout'
        get 'setoutstatus'
        get 'findprintindex'
      end

     resources :order_details
  end



  resources :keyclientorders do
    resources :orders, :controller => 'keyclientorder_orders'
    resources :keyclientorderdetails
  end


  resources :relationships do
    collection do
        get 'select_commodities'
        get 'select_specifications'
       end
    resources :contacts
  end

  resources :shelves do
    get :autocomplete_shelf_shelf_code, :on => :collection
  end


  resources :purchases do
    resources :purchase_details
    member do
      patch 'stock_in'
      patch 'check'
      patch 'close'
    end
  end

  resources :stocks do
    collection do
       get 'findstock'
       get 'getstock'
    end
  end

  resources :areas

  resources :businesses

  resources :stock_logs, only: [:index, :show] do
    member do
      patch 'check'
      get 'split'
    end
    collection do
      get 'stockindex'
      post 'updateall'
      post 'modify'
      post 'removetr'
      post 'addtr'
    end
  end

  resources :goodstypes

  resources :suppliers do
    resources :contacts
  end

  resources :user_logs, only: [:index, :show]

  root 'welcome#index'

  devise_for :users, controllers: { sessions: "users/sessions" }

  
  resources :units do
    resources :users, :controller => 'unit_users'
    resources :storages do
      member do
        get 'change'
      end
    end
  end

  resources :users do
     resources :roles, only: [:index, :new, :create, :show, :destroy]
  end

  resources :storages do
     resources :roles, :controller => 'storage_roles', only: [:index, :new, :create, :show, :destroy]
  end

  resources :commodities do
     resources :specifications
  end

  #stabdar_interface
  match "/standard_interface/commodity_enter" => "standard_interface#commodity_enter", via: [:get, :post]
  match "/standard_interface/order_enter" => "standard_interface#order_enter", via: [:get, :post]
  match "/standard_interface/order_query" => "standard_interface#order_query", via: [:get, :post]
  match "/standard_interface/stock_query" => "standard_interface#stock_query", via: [:get, :post]

  match "/bcm_interface/commodity_enter" => "bcm_interface#commodity_enter", via: [:get, :post]
  match "/bcm_interface/order_enter" => "bcm_interface#order_enter", via: [:get, :post]
  match "/bcm_interface/order_query" => "bcm_interface#order_query", via: [:get, :post]
  match "/bcm_interface/stock_query" => "bcm_interface#stock_query", via: [:get, :post]


  match "/print/tracking" => "print#tracking",via: [:get, :post]
  match "/print/trackingnum" => "print#trackingnum",via: [:get, :post]
  match "/print/keytracking" => "print#keytracking",via: [:get, :post]
  match "/print/keytrackingnum" => "print#keytrackingnum",via: [:get, :post]
  match "/print/webtracking" => "print#webtracking",via: [:get, :post]
  match "/print/webtrackingnum" => "print#webtrackingnum",via: [:get, :post]
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
