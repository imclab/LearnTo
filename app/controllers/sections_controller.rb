class SectionsController < ApplicationController	
  def set_vars
    @creator = User.find(@class_room.creator_id)
	@user = current_user
	@users = @class_room.users
	@user_permission = UserPermission.where("user_id = ? AND class_room_id = ?", @user.id, @class_room.id).first
    if(!@user_permission)
      @user_permission = UserPermission.new
      @show_join = true
    end
  end
  
  def index
	if current_user
	  @resource = Resource.new
	  @section = Section.new
	  @class_room = ClassRoom.find(params[:class_room_id])
	  @sections = @class_room.sections.sort_by { |hws| hws.order }
	  set_vars
	  respond_to do |format|
	  	format.html { render :layout => "show_class_room", :locals => {:which_tab => "homework"} }
	    format.json { render json: @class_room }
	  end
	end
  end
  
  def create
	@section = Section.new(params[:section])
	class_room = ClassRoom.find(params[:class_room_id])
	resource_page = ResourcePage.find(params[:resource_page_id])
	sections = class_room.sections.sort_by { |sec| sec.order }
	@section.order = sections.last.order + 1
	@section.resource_page_id = params[:resource_page_id]
	if(@section.save)
	  redirect_to class_room_resource_page_path(class_room, resource_page)
	else
	  redirect_to class_room_resource_page_path(class_room, resource_page)
	end
  end
  
  def destroy
    @section = Section.find(params[:id])
    @resources = @section.resources
    resource_page = ResourcePage.find(params[:resource_page_id])
    class_room = ClassRoom.find(params[:class_room_id])
    if resource_page.sections.length > 1
      @section.destroy
    end

    respond_to do |format|
      format.html { redirect_to class_room_resource_page_path(class_room, resource_page) }
      format.json { head :no_content }
    end
  end

end