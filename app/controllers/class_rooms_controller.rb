class ClassRoomsController < ApplicationController
  # GET /class_rooms
  # GET /class_rooms.json
  def index
    @class_rooms = ClassRoom.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @class_rooms }
    end
  end
  
  
  def add_user
    @user = current_user
    @user_permission = UserPermission.new(params[:user_permission])
    @class_room = ClassRoom.find(@user_permission.class_room_id)
    if(!UserPermission.where("user_id = ? AND class_room_id = ?", @user.id, @class_room.id).first)
			@user_permission.user_id = @user.id
			@user_permission.permission_type = "student"
			respond_to do |format|
				if @user_permission.save
					format.html { redirect_to class_room_path(@class_room) , notice: 'Class joined successfully!' }
				else
					format.html { redirect_to class_rooms_path , flash => { :fail => 'Error joining class.' } }
				end
			end
    else
      redirect_to class_rooms_path , :flash => { :fail => 'You can\'t join a class more than once!' }
    end
  end
  
  def del_user
    @user_permission=UserPermission.find(params[:perm_id])
    @user = current_user
    @class_room = ClassRoom.find(@user_permission.class_room_id)
    if @user.id == @user_permission.user_id
			@user_permission.destroy
			redirect_to class_room_path(@class_room)
	  else
	    redirect_to class_room_path(@class_room), :flash => { :fail => 'You can only remove yourself from a class' }
	  end
  end
  
  def set_vars
    @creator = User.find(@class_room.creator_id)
    @user = current_user
    @user_permission = UserPermission.where("user_id = ? AND class_room_id = ?", @user.id, @class_room.id).first
    @users = @class_room.users
  end

  # GET /class_rooms/1
  # GET /class_rooms/1.json
  def show
    require_user
    if current_user
      @class_room = ClassRoom.find(params[:id])
      set_vars
      @show_join = false
      
      if(!@user_permission)
        @user_permission = UserPermission.new
        @show_join = true
      end
      
      respond_to do |format|
        format.html { render :layout => "show_class_room", :locals => {:which_tab => "home"} }
        format.json { render json: @class_room }
      end
    end
  end

  # GET /class_rooms/new
  # GET /class_rooms/new.json
  def new
    require_user
    if current_user
      @class_room = ClassRoom.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @class_room }
      end
    end
  end

  # GET /class_rooms/1/edit
  def edit
    @class_room = ClassRoom.find(params[:id])
  end

  # POST /class_rooms
  # POST /class_rooms.json
  def create
    @user = current_user
    @class_room = ClassRoom.new(params[:class_room])
    @class_room.creator_id = @user.id 

    respond_to do |format|
      if @class_room.save
        @homework_section = HomeworkSection.new(:class_room_id => @class_room.id, :order => 0, :title => "All Homework")
        @homework_section.save
        @forum = Forum.new(:class_room_id => @class_room.id)
        @forum.save
        format.html { redirect_to @class_room, notice: 'Class was successfully created.' }
        format.json { render json: @class_room, status: :created, location: @class_room }
      else
        format.html { render action: "new" }
        format.json { render json: @class_room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /class_rooms/1
  # PUT /class_rooms/1.json
  def update
    @class_room = ClassRoom.find(params[:id])

    respond_to do |format|
      if @class_room.update_attributes(params[:class_room])
        format.html { redirect_to @class_room, notice: 'Class was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @class_room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /class_rooms/1
  # DELETE /class_rooms/1.json
  def destroy
    @user = current_user
    @class_room = ClassRoom.find(params[:id])
    if @class_room.creator_id == @user.id
	  @class_room.destroy
	  	
	  respond_to do |format|
	    format.html { redirect_to class_rooms_url }
	    format.json { head :no_content }
	  end
	else
	  redirect_to class_room_path(@class_room), :flash => { :fail => "You do not have permission to modify this class." }
	end
  end
end
