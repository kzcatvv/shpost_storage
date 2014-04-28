class Ability
  include CanCan::Ability

  def initialize(user,storage)
    if user.superadmin?
        can :manage, :all
        # can :role, :unitadmin
        # can :role, :user
        cannot :role, :superadmin
        cannot [:create, :destroy, :update], User, role: 'superadmin'
        can :update, User, id: user.id
        #can :manage, User
    elsif user.unitadmin?

        #can :manage, :all
        can :manage, Business, unit_id: user.unit_id
        can :manage, Supplier, unit_id: user.unit_id
        can :manage, Goodstype, unit_id: user.unit_id
        can :manage, Commodity, unit_id: user.unit_id
        can :manage, Specification, commodity: {unit_id: user.unit_id}
        can :manage, Specification, commodity: {unit_id: user.unit_id}
        can :manage, Relationship, specification: {commodity: {unit_id: user.unit_id}}

        can :manage, Purchase, storage_id: storage.id, status: Purchase::STATUS[:opened]
        can :manage, PurchaseDetail, purchase: {storage_id: storage.id,status: Purchase::STATUS[:opened]}
        can :read, Purchase, storage_id: storage.id, status: Purchase::STATUS[:closed]
        can :read, PurchaseDetail, purchase: {storage_id: storage.id, status: Purchase::STATUS[:closed]}

        can :manage, Keyclientorder, storage_id: storage.id
        can :manage, Keyclientorderdetail, keyclientorder: {storage_id: storage.id}
        can :manage, Order, storage_id: storage.id
        can :manage, OrderDetail, order: {storage_id: storage.id}

        can :read, Unit, id: user.unit_id
        can :manage, Storage, unit_id: user.unit_id

        can :manage, Area, storage_id: storage.id
        can :manage, Shelf, area: {storage_id: storage.id}
        can :new, Shelf
        can :read, Stock, shelf: {area: {storage_id: storage.id}}
        can :new, Stock, shelf: {area: {storage_id: storage.id}}
        can :read, StockLog, stock: {shelf: {area: {storage_id: storage.id}}}
        can :destroy, StockLog, stock: {shelf: {area: {storage_id: storage.id}}}, status: StockLog::STATUS[:waiting]
        can :modify, StockLog, stock: {shelf: {area: {storage_id: storage.id}}}
        can :addtr, StockLog, stock: {shelf: {area: {storage_id: storage.id}}}
        can :removetr, StockLog, stock: {shelf: {area: {storage_id: storage.id}}}

        can :read, UserLog, user: {unit_id: user.unit_id}

        can :manage, User, unit_id: user.unit_id
        can :role, :user
        cannot :role, :superadmin
        cannot :role, :unitadmin
        cannot [:create, :destroy, :update], User, role: ['unitadmin', 'superadmin']
        can :update, User, id: user.id
    else
        can :update, User, id: user.id
        can :manage, Area
        can :manage, Shelf
        
        can :read, :all
        can :change, Storage do |s|
            user.storages.include? s
        end
    end

    

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
  end
end
