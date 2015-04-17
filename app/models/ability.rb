class Ability
  include CanCan::Ability

  def initialize(user,storage = nil)
    user ||= User.new
    if user.superadmin?
        can :manage, User
        can :manage, Unit
        can :manage, UserLog
        can :manage, Role
        can :manage, Storage
        can :role, :unitadmin
        can :role, :user
        can :manage, Specification, commodity: {unit_id: user.unit_id}
        can [:autocomplete_specification_name,:pd_autocomplete_specification_name,:br_autocomplete_specification_name,:ko_autocomplete_specification_name,:os_autocomplete_specification_name,:ms_autocomplete_specification_name,:si_autocomplete_specification_name], Specification, commodity: {unit_id: user.unit_id}
        can :si_autocomplete_specification_name, Relationship, business: {unit_id: user.unit_id}
        # cannot :role, :superadmin
        cannot [:role, :create, :destroy, :update], User, role: 'superadmin'
        can :update, User, id: user.id
        can :manage, Sequence
        #can :manage, User

        can :manage, InterfaceInfo
        can :manage, UpDownload
        can :manage, Logistic

        cannot :resend, InterfaceInfo do |interface_info|
            (interface_info.status == "success") || (interface_info.class_name.blank?) || (interface_info.method_name.blank?)
        end

        
    elsif user.unitadmin?
    #can :manage, :all
        can [:manage,:br_autocomplete_specification_name], Business, unit_id: user.unit_id
        can :manage, Supplier, unit_id: user.unit_id
        can :manage, Contact, supplier: {unit_id: user.unit_id}
        can :manage, Goodstype, unit_id: user.unit_id
        can :manage, Commodity, unit_id: user.unit_id
        can :manage, Specification, commodity: {unit_id: user.unit_id}
        can :new, Relationship
        can :manage, Consumable, unit_id: user.unit_id
        can :manage, ConsumableStock, unit_id: user.unit_id
        can :read, ConstockLog

            # can :manage, MoveStock, unit_id: user.unit_id
            # can :manage, Inventory, unit_id: user.unit_id
            # can :manage, Task, unit_id: user.unit_id

        can [:autocomplete_specification_name,:pd_autocomplete_specification_name,:br_autocomplete_specification_name,:ko_autocomplete_specification_name,:os_autocomplete_specification_name,:ms_autocomplete_specification_name,:si_autocomplete_specification_name], Specification, commodity: {unit_id: user.unit_id}

        can [:manage,:autocomplete_specification_name,:br_autocomplete_specification_name], Relationship, business: {unit_id: user.unit_id}

        can [:read, :update], Unit, id: user.unit_id
        can :manage, Sequence, id: user.unit_id
        can :manage, Storage, unit_id: user.unit_id

        can :storage, Unit, id: user.unit_id

        can :read, UserLog, user: {unit_id: user.unit_id}
        can :destroy, UserLog, operation: '订单导入'

        can :manage, User, unit_id: user.unit_id

        can :manage, Role
        cannot :role, User, role: 'superadmin'
        can :role, :unitadmin
        can :role, :user
        can [:read, :up_download_export, :org_stocks_import, :org_single_stocks_import], UpDownload
        cannot [:create, :to_import, :up_download_import,:destroy], UpDownload
        
        # cannot :role, User, role: 'unitadmin'
        cannot [:create, :destroy, :update], User, role: ['unitadmin', 'superadmin']
        can :update, User, id: user.id

        can :manage, InterfaceInfo

        cannot :resend, InterfaceInfo do |interface_info|
            (interface_info.status == "success") || (interface_info.class_name.blank?) || (interface_info.method_name.blank?)
        end

        can :query_order_report, :orders
        
        # can :manage,BusinessRelationship

    elsif user.user?
        can :update, User, id: user.id
        can :read, UserLog, user: {id: user.id}

        can :read, Unit, id: user.unit_id


        can :read, Business, unit_id: user.unit_id
        can :read, Supplier, unit_id: user.unit_id
        can :read, Contact, supplier: {unit_id: user.unit_id}
        can :read, Goodstype, unit_id: user.unit_id
        can :read, Commodity, unit_id: user.unit_id
        can :read, Specification, commodity: {unit_id: user.unit_id}

        can :autocomplete_specification_name, Specification, commodity: {unit_id: user.unit_id}

        can :read, Relationship, business: {unit_id: user.unit_id}

        cannot :manage, InterfaceInfo

        can [:read, :up_download_export], UpDownload
        cannot [:create, :to_import, :up_download_import,:destroy], UpDownload

        cannot :query_order_report, :orders

    else
        cannot :manage, :all
        #can :update, User, id: user.id
        cannot :read, User
        cannot :read, Area
        cannot :read, Commodity
        cannot :read, Business

        cannot :manage, InterfaceInfo
        can :query_order_report, :orders
    end

    if user.admin?(storage)
        can :change, Storage, id: storage.id

        can :manage, Purchase, storage_id: storage.id, status: Purchase::STATUS[:opened]

        can :manage, PurchaseDetail, purchase: {storage_id: storage.id, status: Purchase::STATUS[:opened]}
        
        can :manage, PurchaseArrival, purchase_detail: {purchase: {storage_id: storage.id, status: Purchase::STATUS[:opened]}}

        can :read, Purchase, storage_id: storage.id, status: Purchase::STATUS[:closed]

        can :read, PurchaseDetail, purchase: {storage_id: storage.id, status: Purchase::STATUS[:closed]}

        can :read, PurchaseArrival, purchase_detail: {purchase: {storage_id: storage.id, status: Purchase::STATUS[:opened]}}

        cannot :close, Purchase do |purchase|
            (purchase.storage_id == storage.id) && (purchase.status == Purchase::STATUS[:opened]) && !purchase.can_close?
        end

        cannot :update, PurchaseDetail do |purchase_detail|
            (purchase_detail.purchase.storage_id == storage.id) && (purchase_detail.status == PurchaseDetail::STATUS[:stock_in])
        end

        cannot :destroy, PurchaseDetail do |purchase_detail|
            (purchase_detail.purchase.storage_id == storage.id) && (purchase_detail.status == PurchaseDetail::STATUS[:stock_in])
        end

        can :manage, ManualStock, storage_id: storage.id, status: ManualStock::STATUS[:opened]

        can :manage, ManualStockDetail, manual_stock: {storage_id: storage.id, status: ManualStock::STATUS[:opened]}

        can :read, ManualStock, storage_id: storage.id, status: ManualStock::STATUS[:closed]

        can :read, ManualStockDetail, manual_stock: {storage_id: storage.id, status: ManualStock::STATUS[:closed]}

        cannot :close, ManualStock do |manual_stock|
            (manual_stock.storage_id == storage.id) && (manual_stock.status == ManualStock::STATUS[:opened]) && !manual_stock.can_close?
        end

        cannot :update, ManualStockDetail do |manual_stock_detail|
            (manual_stock_detail.manual_stock.storage_id == storage.id) && (manual_stock_detail.status == ManualStockDetail::STATUS[:stock_out])
        end

        cannot :destroy, ManualStockDetail do |manual_stock_detail|
            (manual_stock_detail.manual_stock.storage_id == storage.id) && (manual_stock_detail.status == ManualStockDetail::STATUS[:stock_out])
        end

        can :manage, Keyclientorder, storage_id: storage.id
        can :manage, Keyclientorderdetail, keyclientorder: {storage_id: storage.id}

        can :manage, Order, storage_id: storage.id
        can :query_order_report, :orders
        cannot :cancel, Order, status: ['printed','picking']
        can :manage, OrderDetail, order: {storage_id: storage.id}

        # can :manage, Role, storage_id: storage.id

        can :manage, Area, storage_id: storage.id

        can :new, Shelf
        can :manage, Shelf, area: {storage_id: storage.id}

        can :new, Stock
        can :manage, Stock, shelf: {area: {storage_id: storage.id} }

        can :manage, MoveStock, unit_id: user.unit_id
        can :manage, Inventory, unit_id: user.unit_id
        # can [:read, :getstock, :findstock], Stock, shelf: {area: {storage_id: storage.id}}

        # can :new, Stock, shelf: {area: {storage_id: storage.id}}
        can :manage, StockLog, shelf: {area: {storage_id: storage.id}}
        # can :destroy, StockLog, stock: {shelf: {area: {storage_id: storage.id}}}, status: StockLog::STATUS[:waiting]
        # can :modify, StockLog, stock: {shelf: {area: {storage_id: storage.id}}}
        # can :addtr, StockLog, stock: {shelf: {area: {storage_id: storage.id}}}
        # can :check, StockLog, stock: {shelf: {area: {storage_id: storage.id}}}
        # can :removetr, StockLog, stock: {shelf: {area: {storage_id: storage.id}}}
        cannot :destroy, StockLog, status: "checked"
        cannot :split, StockLog, status: "checked"

        can :manage, OrderReturn, storage_id: storage.id, status: Purchase::STATUS[:opened]

        can :autocomplete_specification_name, Specification, commodity: {unit_id: user.unit_id}

        can :manage, Mobile, storage_id: storage.id

        can :read, Task, storage_id: storage.id

        
    end

    if user.order?(storage)
        can :change, Storage, id: storage.id

        can :manage, Keyclientorder, storage_id: storage.id
        can :manage, Keyclientorderdetail, keyclientorder: {storage_id: storage.id}

        can :manage, Order, storage_id: storage.id
        can :manage, OrderDetail, order: {storage_id: storage.id}

        can :manage, OrderReturn, storage_id: storage.id, status: Purchase::STATUS[:opened]

        # can :new, Stock
        can :read, Stock, shelf: {area: {storage_id: storage.id} }
        can :ready2bad, Stock, shelf: {area: {storage_id: storage.id} }
        can :move2bad, Stock, shelf: {area: {storage_id: storage.id} }

        can :read, StockLog, shelf: {area: {storage_id: storage.id}}

        can :autocomplete_specification_name, Specification, commodity: {unit_id: user.unit_id}

        can :read, Task, storage_id: storage.id
    end

    if user.purchase?(storage)
        can :change, Storage, id: storage.id

        can :manage, Purchase, storage_id: storage.id, status: Purchase::STATUS[:opened]

        can :manage, PurchaseDetail, purchase: {storage_id: storage.id, status: Purchase::STATUS[:opened]}

        can :read, Purchase, storage_id: storage.id, status: Purchase::STATUS[:closed]

        can :read, PurchaseDetail, purchase: {storage_id: storage.id, status: Purchase::STATUS[:closed]}

        cannot :close, Purchase do |purchase|
            (purchase.storage_id == storage.id) && (purchase.status == Purchase::STATUS[:opened]) && !purchase.can_close?
        end

        can :read, Stock, shelf: {area: {storage_id: storage.id} }

        can :read, StockLog, shelf: {area: {storage_id: storage.id}}

        can :autocomplete_specification_name, Specification, commodity: {unit_id: user.unit_id}
    end

    if user.packer?(storage)
        can :change, Storage, id: storage.id

        can :read, Order, storage_id: storage.id
        can :findorderout, Order, storage_id: storage.id
        can :setoutstatus, Order, storage_id: storage.id
        can :packout, Order, storage_id: storage.id
        can :packaging_index, Order, storage_id: storage.id
        can :packaged_index, Order, storage_id: storage.id
        
    end

    if user.sorter?(storage)
        can :change, Storage, id: storage.id

        can :manage, Purchase, storage_id: storage.id, status: Purchase::STATUS[:opened]

        can :manage, PurchaseDetail, purchase: {storage_id: storage.id, status: Purchase::STATUS[:opened]}

        can :read, Purchase, storage_id: storage.id, status: Purchase::STATUS[:closed]

        can :read, PurchaseDetail, purchase: {storage_id: storage.id, status: Purchase::STATUS[:closed]}

        cannot :close, Purchase do |purchase|
            (purchase.storage_id == storage.id) && (purchase.status == Purchase::STATUS[:opened]) && !purchase.can_close?
        end

        cannot :update, PurchaseDetail do |purchase_detail|
            (purchase_detail.purchase.storage_id == storage.id) && (purchase_detail.status == PurchaseDetail::STATUS[:stock_in])
        end

        cannot :destroy, PurchaseDetail do |purchase_detail|
            (purchase_detail.purchase.storage_id == storage.id) && (purchase_detail.status == PurchaseDetail::STATUS[:stock_in])
        end

        can :manage, ManualStock, storage_id: storage.id, status: ManualStock::STATUS[:opened]

        can :manage, ManualStockDetail, manual_stock: {storage_id: storage.id, status: ManualStock::STATUS[:opened]}

        can :read, ManualStock, storage_id: storage.id, status: ManualStock::STATUS[:closed]

        can :read, ManualStockDetail, manual_stock: {storage_id: storage.id, status: ManualStock::STATUS[:closed]}

        cannot :close, ManualStock do |manual_stock|
            (manual_stock.storage_id == storage.id) && (manual_stock.status == ManualStock::STATUS[:opened]) && !manual_stock.can_close?
        end

        cannot :update, ManualStockDetail do |manual_stock_detail|
            (manual_stock_detail.manual_stock.storage_id == storage.id) && (manual_stock_detail.status == ManualStockDetail::STATUS[:stock_out])
        end

        cannot :destroy, ManualStockDetail do |manual_stock_detail|
            (manual_stock_detail.manual_stock.storage_id == storage.id) && (manual_stock_detail.status == ManualStockDetail::STATUS[:stock_out])
        end

        can :read, Stock, shelf: {area: {storage_id: storage.id} }
        can :ready2bad, Stock, shelf: {area: {storage_id: storage.id} }
        can :move2bad, Stock, shelf: {area: {storage_id: storage.id} }

        can :manage, MoveStock, unit_id: user.unit_id
        can :read, StockLog, shelf: {area: {storage_id: storage.id}}
        can :manage, Inventory, unit_id: user.unit_id

        can :autocomplete_specification_name, Specification, commodity: {unit_id: user.unit_id}
        
    end

    end
end




# if user.admin?(storage)


# Define abilities for the passed in user here. For example:
#
#   user ||= User.new # guest user (not logged in)
#   if user.admin?
#     can :manage, :all
#   else
#     can :read, :all
#   end
#
# The first argument to `can` is the action you are giving the user 
# permission to do.
# If you pass :manage it will apply to every action. Other common actions
# here are :read, :create, :update and :destroy.
#
# The second argument is the resource the user can perform the action on. 
# If you pass :all it will apply to every resource. Otherwise pass a Ruby
# class of the resource.
#
# The third argument is an optional hash of conditions to further filter the
# objects.
# For example, here the user can only update published articles.
#
#   can :update, Article, :published => true
#
# See the wiki for details:
# https://github.com/ryanb/cancan/wiki/Defining-Abilities
