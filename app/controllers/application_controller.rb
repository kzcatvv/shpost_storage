class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  rescue_from Exception, with: :get_errors if Rails.env.production?

  rescue_from CanCan::AccessDenied, with: :access_denied if Rails.env.production?

  protect_from_forgery with: :exception

  before_filter :configure_charsets
  before_filter :authenticate_user!

  def self.user_logs_filter *args
    after_filter args.first.select{|k,v| k == :only || k == :expert} do |controller|
      save_user_log args.first.reject{|k,v| k == :only || k == :expert}
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, session[:current_storage])
  end

  def current_storage
    session[:current_storage]
  end

  def configure_charsets
    headers["Content-Type"]="text/html;charset=utf-8"
  end

  def save_user_log *args
    object = eval("@#{args.first[:object].to_s}")

    object ||= eval("@#{controller_name.singularize}")

    operation = args.first[:operation]
    
    operation ||= I18n.t("action_2_operation.#{action_name}") + object.class.model_name.human.to_s

    symbol = args.first[:symbol]
    
    @user_log = UserLog.new(user: current_user, operation: operation)

    if object
      if object.errors.blank?
        @user_log.object_class = object.class.to_s
        @user_log.object_primary_key = object.id

        if symbol && object[:symbol]
          @user_log.object_symbol = object[:symbol]
        else
          @user_log.object_symbol = object.id
        end
        @user_log.save
      end
    else
      @user_log.save
    end
  end
     
  private
  def access_denied exception
    @error_title = I18n.t 'errors.access_deny.title', default: 'Access Denied!'
    @error_message = I18n.t 'errors.access_deny.message', default: 'The user has no permission to vist this page'
    render template: '/errors/error_page',layout: false
  end

  def get_errors exception
    puts exception
    puts exception.backtrace
    Rails.logger.error(exception)

    @error_title = I18n.t 'errors.get_errors.title', default: 'Get An Error!'
    @error_message = I18n.t 'errors.get_errors.message', default: 'The operation you did get an error'
    render :template => '/errors/error_page',layout: false
  end

end
