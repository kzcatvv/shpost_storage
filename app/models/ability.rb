class Ability
  include CanCan::Ability

  def initialize(user)
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
        can :manage, Supplier, unit_id: user.unit_id
        can :manage, Goodstype, unit_id: user.unit_id
        can :manage, Commodity, unit_id: user.unit_id

        can :manage, :all
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
        can :change, Storage do |storage|
            user.storages.include? storage
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
