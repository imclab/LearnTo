class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user

  private
    before_filter :global_vars

    def global_vars
      @website_name = "LearnTo"
    end
    
    def require_enrolled(class_room)
      user = current_user
      user_permission = current_user ? UserPermission.where("user_id = ? AND class_room_id = ?", user.id, class_room.id).first.try(:permission_type) : "none"
      unless is_creator(class_room) || user_permission == "student"
        flash[:fail] = "You must be enrolled to view this page"
        redirect_back_or_default class_room
      end
    end
    
    def is_enrolled(class_room)
      if current_user
        user = current_user
        user_permission = current_user ? UserPermission.where("user_id = ? AND class_room_id = ?", user.id, class_room.id).first.try(:permission_type) : "none"
        unless is_creator(class_room) || user_permission == "student"
          flash[:fail] = "You must be enrolled to view this page"
          redirect_back_or_default class_room
        end
      end
      
      def is_enrolled(class_room)
        if current_user
          user = current_user
          user_permission = UserPermission.where("user_id = ? AND class_room_id = ?", user.id, class_room.id).first.try(:permission_type)
          return is_creator(class_room) || (user_permission == "student" && class_room.started)
        else
          return false
        end
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
    
    def is_creator(item)
      user = current_user
      return current_user && user.id == item.user_id
    end
  
    def set_vars
      @resource_pages = @class_room.resource_pages.sort_by {|x| x.id}
      @creator = User.find(@class_room.user_id)
      if current_user
        @is_creator = is_creator(@class_room)
        @user = current_user
        @user_permission = UserPermission.where("user_id = ? AND class_room_id = ?", @user.id, @class_room.id).first
      end
      @users = @class_room.users
      if(!@is_creator)
        if(!@user_permission && current_user)
          @user_permission = UserPermission.new
          @show_join = true
        elsif current_user
          @user_type = @user_permission.permission_type
        else
          @user_type = "none"
        end
      end
    end  
  
    def class_notification(action, item_type, class_room, item_id)
      #note type must be post (for now) then resource
      class_room.users.each do |user|
        notification = Notification.new(:action => action, :item_type => item_type, :user_id => user.id, :read => false, :item_id => item_id)
        notification.save
      end
    end
    
    def user_notification(action, item_type, user, item_id)
      #note type must be post (for now) then resource
      notification = Notification.new(:action => action, :item_type => item_type, :user_id => user.id, :read => false, :item_id => item_id)
      notification.save
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
    
    def get_notifications
      @notifications = current_user.notifications
      .select('action, max(user_id) as user_id, read, item_type, item_id, count(*) as count, max(created_at) as created_at')
      .group('action, read, item_type, item_id')
      .order('read')
      .order('created_at DESC')
    end
  
    def store_location
      session[:return_to] = request.url
    end
  
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end

