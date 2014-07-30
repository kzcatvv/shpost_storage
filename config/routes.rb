ShpostStorage::Application.routes.draw do


  resources :orderreturns do
    collection do
      get 'packreturn'
      get 'doreturn'
      get 'findtrackingnumber'
      get 'returncheck'
    end
  end

  resources :contacts do
    get 'relation', on: :collection
    get 'deleterelation', on: :member
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
        get 'order_alert'
        get 'pingan_b2b_import'
        post 'pingan_b2b_import' => 'orders#pingan_b2b_import'
        get 'pingan_b2c_import'
        post 'pingan_b2c_import' => 'orders#pingan_b2c_import'
        get 'pingan_b2c_outport'
        post 'pingan_b2c_xls_outport'
        get 'pingan_b2b_outport'
        post 'pingan_b2b_xls_outport'
        post 'exportorders'
        get 'importorders'
        post 'importorders' => 'orders#importorders'
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
        get 'findwarningamt'
      get 'relationship_import'
      post 'relationship_import' => 'relationships#relationship_import'
      get 'specification_export'
      post 'specification_export' => 'relationships#specification_export'
    end
    resources :contacts
  end

  resources :shelves do
    get :autocomplete_shelf_shelf_code, :on => :collection
    collection do 
      get 'shelf_import'
      post 'shelf_import' => 'shelves#shelf_import'
    end
  end


  resources :purchases do
    resources :purchase_details
      collection do 
      get  'purchase_import'
      post 'purchase_import' => 'purchases#purchase_import'
      end

    member do
      patch 'onecheck'
      get 'stock_in'
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

  #resources :storages do
  #   resources :roles, :controller => 'storage_roles', only: [:index, :new, :create, :show, :destroy]
  #end

  resources :roles,controller: 'unit_roles', only: [:index, :new, :create, :show, :destroy] do
    collection do
        get 'findroledtl'
    end
  end

 resources :storages, controller: 'unit_storage', only: [:index, :new, :create, :show, :destroy,:edit,:update] do
     resources :roles, :controller => 'storage_roles', only: [:index, :new, :create, :show, :destroy]
  collection do
        get 'findroledtl'
    end
   end

  resources :commodities do
     resources :specifications
      collection do 
      get 'commodity_import'
      post 'commodity_import' => 'commodities#commodity_import'
    end
  end

  


  resources :areas do
     resources :shelves, :controller => 'area_shelf'
  end

  #stabdar_interface
  match "/shpost_storage/standard_interface/commodity_enter" => "standard_interface#commodity_enter", via: [:get, :post]
  match "/shpost_storage/standard_interface/order_enter" => "standard_interface#order_enter", via: [:get, :post]
  match "/shpost_storage/standard_interface/order_query" => "standard_interface#order_query", via: [:get, :post]
  match "/shpost_storage/standard_interface/stock_query" => "standard_interface#stock_query", via: [:get, :post]

  match "/shpost_storage/bcm_interface/commodity_enter" => "bcm_interface#commodity_enter", via: [:get, :post]
  match "/shpost_storage/bcm_interface/order_enter" => "bcm_interface#order_enter", via: [:get, :post]
  match "/shpost_storage/bcm_interface/order_query" => "bcm_interface#order_query", via: [:get, :post]
  match "/shpost_storage/bcm_interface/stock_query" => "bcm_interface#stock_query", via: [:get, :post]


  match "/print/tracking" => "print#tracking",via: [:get, :post]
  match "/print/trackingnum" => "print#trackingnum",via: [:get, :post]
  match "/print/keytracking" => "print#keytracking",via: [:get, :post]
  match "/print/keytrackingnum" => "print#keytrackingnum",via: [:get, :post]
  match "/print/webtracking" => "print#webtracking",via: [:get, :post]
  match "/print/webtrackingnum" => "print#webtrackingnum",via: [:get, :post]

  match "/contact/add" => "contacts#add",via: [:get, :post]
  match "/contact/confirmadd" => "contacts#confirmadd",via: [:get, :post]
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
