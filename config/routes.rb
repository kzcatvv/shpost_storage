ShpostStorage::Application.routes.draw do

  resources :tasks

  resources :mobiles

  resources :move_stocks do
    collection do
      patch 'check'
    end
    member do
      get 'movedetail'
    end
  end

  resources :up_downloads do
    collection do 
      get 'up_download_import'
      post 'up_download_import' => 'up_downloads#up_download_import'
      
      get 'to_import'
      get 'org_stocks_import'
      post 'org_stocks_import' => 'up_downloads#org_stocks_import'
      get 'select_unit'
      
    end
    member do
      get 'up_download_export'
      post 'up_download_export' => 'up_downloads#up_download_export'
    end
  end

  
  resources :manual_stocks do
    collection do 
      get  'manual_stock_import'
      post 'manual_stock_import' => 'manual_stocks#manual_stock_import'
    end

    member do
      patch 'onecheck'
      get 'stock_out'
      get 'assign'
      post 'assign_select'
      patch 'check'
      patch 'close'
      get 'scan'
      post 'scan_check'
    end
    resources :manual_stock_details
  end

  resources :interface_infos do
    member do
      get 'resend'
    end
  end

  resources :order_returns do
    collection do
      get 'pack_return'
      get 'do_return'
      get 'find_tracking_number'
      get 'return_check'
      post 'export_order_returns' => 'order_returns#export_order_returns'
      get 'export_order_returns'
    end
  end

  resources :contacts do
    get 'relation', on: :collection
    get 'deleterelation', on: :member
  end

  resources :orders do
     collection do
        get 'findprint'
        # get 'stockout'
        # get 'ordercheck'
        get 'nextbatch'
        get 'packout'
        get 'packaging_index'
        get 'packaged_index'
        get 'findorderout'
        get 'setoutstatus'
        get 'findprintindex'
        get 'order_alert'
        get 'pingan_b2b_import'
        post 'pingan_b2b_import' => 'orders#pingan_b2b_import'
        get 'pingan_b2c_import'
        post 'pingan_b2c_import' => 'orders#pingan_b2c_import'
        get 'orders_b2b_import'
        post 'orders_b2b_import' => 'orders#orders_b2b_import'
        get 'standard_orders_import'
        post 'standard_orders_import' => 'orders#standard_orders_import'
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
    collection do
        get 'b2bindex'
        get 'b2bstockout'
        get 'b2boutcheck'
        get 'b2bordersplit'
        get 'b2bfind69code'
        get 'b2bsplitanorder'
        get 'b2bsettrackingnumber'
        get 'ordercheck'
    end
    resources :orders, :controller => 'keyclientorder_orders'
    resources :keyclientorderdetails
    member do
      post 'pdjs'
      get 'stockout'
      get 'assign'
      post 'assign_select'
    end
  end


  resources :relationships do
    collection do
        get 'select_commodities'
        get 'select_specifications'
      get 'relationship_import'
      post 'relationship_import' => 'relationships#relationship_import'
      get 'specification_export'
      post 'specification_export' => 'relationships#specification_export'
    end
    resources :contacts
  end

  resources :shelves do
    get :autocomplete_shelf_shelf_code, :on => :collection
    get :autocomplete_pick_shelf_code, :on => :collection
    get :autocomplete_bad_shelf_code, :on => :collection
    get :autocomplete_shelf_code_by_stockimp, :on => :collection
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
      get 'assign'
      post 'assign_select'
      patch 'check'
      patch 'close'
      get "scan"
      post "scan_check"
    end
  end

  resources :purchase_details do
    resources :purchase_arrivals
  end

  resources :stocks do
    collection do
      get 'warning_stocks_index'
      get 'findstock'
      get 'getstock'
      get 'find_stock_in_shelf'
      get 'find_stock_amount'
    end

    member do
      get 'move2bad'
      get 'ready2bad'
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
      post 'purchase_modify'
      post 'remove'
      post 'move_stock_modify'
      post 'move_stock_remove'
      post 'manual_stock_modify'
      post 'keyclientorder_stock_modify'
    end
  end

  resources :goodstypes

  resources :suppliers do
    resources :contacts
    collection do 
      get 'supplier_import'
      post 'supplier_import' => 'suppliers#supplier_import'
    end
  end

  resources :user_logs, only: [:index, :show]

  root 'welcome#index'

  devise_for :users, controllers: { sessions: "users/sessions" }

  
  resources :units do
    resources :users, :controller => 'unit_users'
    resources :storages, :controller => 'unit_storages'
    resources :sequences, :controller => 'unit_sequences'
  end

  resources :users do
     resources :roles, :controller => 'user_roles'
  end

  # resources :roles

  #resources :storages do
  #   resources :roles, :controller => 'storage_roles', only: [:index, :new, :create, :show, :destroy]
  #end

  # resources :roles,controller: 'unit_roles', only: [:index, :new, :create, :show, :destroy] do
  #   collection do
  #       get 'findroledtl'
  #   end
  # end

 resources :storages do
    resources :roles, :controller => 'storage_roles'
    collection do
      get 'findroledtl'
    end
    member do
      get 'change'
    end
   end

  resources :commodities do
     resources :specifications
      collection do 
      get 'commodity_import'
      post 'commodity_import' => 'commodities#commodity_import'
    end
  end

  resources :specification_autocom do
      collection do
        get 'autocomplete_specification_name'
        get 'pd_autocomplete_specification_name'
        get 'br_autocomplete_specification_name'
        get 'ko_autocomplete_specification_name'
        get 'os_autocomplete_specification_name'
        get 'ms_autocomplete_specification_name'
        get 'si_autocomplete_specification_name'
     end
  end

  resources :areas do
     resources :shelves, :controller => 'area_shelf'
  end

  resources :businesses do
     resources :relationships, :controller => 'business_relationship'
  end

  # get 'scans' => 'scans#scans'
  # post 'scans_check' => 'scans#scans_check'

  # report
  match "/shpost_storage/report/purchase_arrival_report" => "report#purchase_arrival_report", via: [:get, :post]
  match "/shpost_storage/report/stock_stat_report" => "report#stock_stat_report", via: [:get, :post]

  #stabdar_interface
  match "/shpost_storage/standard_interface/commodity_enter" => "standard_interface#commodity_enter", via: [:get, :post]
  match "/shpost_storage/standard_interface/order_enter" => "standard_interface#order_enter", via: [:get, :post]
  # match "/shpost_storage/standard_interface/order_query" => "standard_interface#order_query", via: [:get, :post]
  match "/shpost_storage/standard_interface/orders_query" => "standard_interface#orders_query", via: [:get, :post]
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
  match "/print/websplitordertracking" => "print#websplitordertracking",via: [:get, :post]
  match "/print/websplitordertrackingnum" => "print#websplitordertrackingnum",via: [:get, :post]
  match "/print/shelfbarcodeprint" => "print#shelfbarcodeprint",via: [:get, :post]
  match "/print/relationbarcodeprint" => "print#relationbarcodeprint",via: [:get, :post]


  match "/contact/add" => "contacts#add",via: [:get, :post]
  match "/contact/confirmadd" => "contacts#confirmadd",via: [:get, :post]

  match "/shpost_storage/mobile_interface/login" => "mobile_interface#login", via: [:get, :post]
  match "/shpost_storage/mobile_interface/logout" => "mobile_interface#logout", via: [:get, :post]
  match "/shpost_storage/mobile_interface/mission" => "mobile_interface#mission", via: [:get, :post]
  match "/shpost_storage/mobile_interface/mission_details" => "mobile_interface#mission_details", via: [:get, :post]
  match "/shpost_storage/mobile_interface/mission_upload" => "mobile_interface#mission_upload", via: [:get, :post]
  match "/shpost_storage/mobile_interface/query" => "mobile_interface#query", via: [:get, :post]

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
