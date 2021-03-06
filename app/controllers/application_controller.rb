class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user, :user_notifications_number

  private
    before_filter :global_vars

  def global_vars
    @website_name = "LearnTo"
  end
  
  def is_admin #lulz
    user = current_user
    return current_user && (user.email == "brodrick.childs@gmail.com" || user.email == "jtwarren@mit.edu" || user.email == "sashko@mit.edu")
  end
  
  def require_admin
    unless is_admin
      flash[:fail] = "You must be the site administrator to do that"
      redirect_to root_path
    end
  end
  
  def require_enrolled(class_room)
    user = current_user
    user_permission = current_user ? UserPermission.where("user_id = ? AND class_room_id = ?", user.id, 
    class_room.id).first.try(:permission_type) : "none"
    unless is_enrolled(class_room)
      flash[:fail] = (user_permission == "student") ? "You'll be able to view this page once the class has started." : "Enroll in the class to view this page."
      redirect_back_or_default class_room
    end
  end
  
  def is_enrolled(class_room)
    if current_user
      user = current_user
      user_permission = UserPermission.where("user_id = ? AND class_room_id = ?", user.id, 
      class_room.id).first.try(:permission_type)
      if is_creator(class_room) || (user_permission == "student" && class_room.started)
        return true
      else
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
    return (current_user && user.id == item.user_id) || is_admin
  end

  def set_vars
    @is_admin = is_admin
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

  #Send a notification to a class
  def class_notification(action, item_type, class_room, item_id, parent_id)
    #note type must be post (for now) then resource
    class_room.users.each do |user|
			notification = Notification.new(:action => action, :item_type => item_type, :user_id => user.id, 
			:read => false, :item_id => item_id, :parent_id => parent_id)
			notification.save
    end
  end
  
  #Send a notification to a particular user
  def user_notification(action, item_type, user, item_id, parent_id)
    #note type must be post (for now) then resource
    if current_user.id != user.id
      notification = Notification.new(:action => action, :item_type => item_type, :user_id => user.id, 
      :read => false, :item_id => item_id, :parent_id => parent_id)
      notification.save
    end
  end
  
  
  def user_notifications
    @notifications = []
    if current_user
      notifications = current_user.notifications.order('read').order('created_at DESC')
      id_type_set = {}
      notifications.each {|notification| id_type_set[[notification.action, notification.read, 
      notification.item_type, notification.parent_id]] = 1}
      
      id_type_set.keys.each do |key| 
        matching_notifications = notifications.select {|n| n.action == key[0] and n.read == key[1] and 
        n.item_type == key[2] and n.parent_id == key[3]}
        @notifications.push(matching_notifications)
      end
    end
  end
  
  def user_notifications_number
    if current_user
      user_notifications
      @notifications_number = @notifications.select {|n| n.first.read == false}.length
      @notifications_number = @notifications_number > 9 ? "9+" : @notifications_number
    else
      return 0
    end
  end

  def require_no_user
    logger.debug "ApplicationController::require_no_user"
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page."
      redirect_to root_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.url
  end
  
  def activity_by_user_and_class_id(user_id, class_room_id)
    @list = []
    #new responses in forum
    #we can make this more efficient but its fine for now
    ClassRoom.first.forum.posts.each do |x|
      @list.push(x.comments.where("created_at >= ?", Date.today - 30.days).where(:user_id => user_id).count(:order => 'DATE(created_at)', :group => ["DATE(created_at)"]))
    end

    #new announcements
    @list.push(Announcement.where("created_at >= ?", Date.today - 30.days).where('user_id = ?', user_id).where('class_room_id = ?', class_room_id).count(:order => 'DATE(created_at)', :group => ["DATE(created_at)"]))

    #new resources
    @list.push(Resource.where("created_at >= ?", Date.today - 30.days).where('user_id = ?', 1).where('class_room_id = ?', 1).count(:order => 'DATE(created_at)', :group => ["DATE(created_at)"]))
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
