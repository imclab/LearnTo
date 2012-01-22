class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user


  private
    before_filter :global_vars

    def global_vars
      @website_name = "ClassBox"
    end
    
    def current_user_session
      logger.debug "ApplicationController::current_user_session"
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      logger.debug "ApplicationController::current_user"
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
    
    def require_user
      logger.debug "ApplicationController::require_user"
      unless current_user
        store_location
        flash[:fail] = "You must be logged in to access this page."
        redirect_to login_path
        return false
      end
    end
    
    def is_creator(class_room)
      user = current_user
      if user.id == class_room.creator_id
        return true
      end
      return false
    end
  
  def set_vars
    @resource_pages = @class_room.resource_pages.sort_by {|x| x.id}
    @creator = User.find(@class_room.creator_id)
    @user = current_user
    @user_permission = UserPermission.where("user_id = ? AND class_room_id = ?", @user.id, @class_room.id).first
    @users = @class_room.users
    if(!@user_permission)
      @user_permission = UserPermission.new
      @show_join = true
    end
  end  

    def require_no_user
      logger.debug "ApplicationController::require_no_user"
      if current_user
        store_location
        flash[:fail] = "You must be logged out to access this page."
        redirect_to root_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.url
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end

