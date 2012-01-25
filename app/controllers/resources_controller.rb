class ResourcesController < ApplicationController
  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @resources }
    end
  end

  def get_path_vars	
    @class_room = ClassRoom.find(params[:class_room_id])
    @section = Section.find(params[:section_id])
    @resource_page = ResourcePage.find(params[:resource_page_id])
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
    @resource = Resource.find(params[:id])
    get_path_vars
    set_vars
    
    if(@resource.file_type == "document")
      @document = @resource.document
      unless defined? @document.parsed_content and Rails.env == "production"
        xml_doc = Nokogiri::HTML(@document.content)
        xml_doc.css('a.media_replace').each do |link| 
          res = Resource.find(link.attribute("href").value)
          link.replace(
            render_to_string :partial => "shared/embed",
                :locals => {:res => res, :style => "big_embed", :hidden => false}
          )
        end
      end

      @document.parsed_content = xml_doc.to_s
      @document.save
    end


    respond_to do |format|
      format.html { render :layout => "show_class_room", :locals => {:which_tab => @resource_page.section} }
      format.json { render json: @resource }
    end
  end

  # GET /resources/new
  # GET /resources/new.json
  def new
	require_user
	
		if current_user
			@resource = Resource.new

			respond_to do |format|
				format.html # new.html.erb
				format.json { render json: @resource }
			end
		end
  end

  # GET /resources/1/edit
  def edit
    @resource = Resource.find(params[:id])
    get_path_vars
    set_vars
    @sections = @class_room.sections
    if(@resource.file_type == "document")
      @document = @resource.document
    end
    respond_to do |format|
	    format.html { render :layout => "show_class_room", :locals => {:which_tab => @resource_page.section} }
	    format.json { render json: @resource }
	  end
  end

  # POST /resources
  # POST /resources.json
  def create	
		@resource = Resource.new(params[:resource])
		@class_room = ClassRoom.find(params[:class_room_id])
		@resource_page = ResourcePage.find(params[:resource_page_id])
		@section = Section.find(params[:section][:id])
	  set_vars
	  if @is_creator
			#set resource info not from form
			@resource.source_call = @resource_page.section
			@resource.user_id = @user.id 
			@resource.class_room_id = @class_room.id
			@resource.section_id = @section.id
			@resource.hidden = false
			@resource.order = @section.resources.length
				
			#handle documents
			if @resource.file_type == "document"
				@resource.hidden = true
			end
				
			#Makes the document-resource relationship if the document and resource are both valid -- need to put in validations
				if @resource.save
					unless @resource.hidden
						@class_room.update_attribute(:updated_at, Time.now.to_datetime)
					end
					if @resource.file_type == "document"
					@document = Document.new
					@document.resource_id = @resource.id
					@document.save
					redirect_to edit_class_room_resource_page_section_resource_path(@class_room, @resource_page, @section, @resource)
				else
					redirect_to class_room_resource_page_path(@class_room, @resource_page)
				end
			else
				redirect_to class_room_resource_page_path(@class_room, @resource_page)
			end
		else
		  redirect_to class_room_resource_page_path(@class_room, @resource_page), :flash => { :fail => "You must be the owner of this class to upload resources"}
		end
  end
  
  # PUT /resources/1
  # PUT /resources/1.json
  def update
    @resource = Resource.find(params[:id])
    @class_room = ClassRoom.find(@resource.class_room_id)
    @resource_page = ResourcePage.find(params[:resource_page_id])
    @section = Section.find(params[:section_id])

		if is_creator(@class_room)
      respond_to do |format|
        if @resource.update_attributes(params[:resource])
          if(@resource.file_type == "document")
            @document = @resource.document
            @document.content = params[:document][:content]

            xml_doc = Nokogiri::HTML(@document.content)
            xml_doc.css('a.media_replace').each do |link| 
              res = Resource.find(link.attribute("href").value)
              link.replace(
                render_to_string :partial => "shared/embed",
                    :locals => {:res => res, :style => "big_embed", :hidden => false}
              )
            end
            
            @document.parsed_content = xml_doc.to_s
            @document.save
          end
          unless @resource.hidden
            @class_room.update_attribute(:updated_at, Time.now.to_datetime)
          end
          format.html { redirect_to class_room_resource_page_section_resource_path(@class_room, @resource_page, @section, @resource),
           notice: 'Resource was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end
		else
		  redirect_back_or_default class_room_resource_page_section_resource_path(@class_room, @resource_page, @section, @resource),
		   :flash => { :fail => "You must be the creator of the class to modify uploaded documents" }
		end
  end


  
  def change_hidden
    #make sure we don't update updated_at when just changing order or publishing
    Resource.record_timestamps = false
    
    get_path_vars
    @resource = Resource.find(params[:id])
    if @resource.hidden
      @resource.update_attribute(:hidden, false)
    else
      @resource.update_attribute(:hidden, true)
    end
    
    #Turn timestamps back on    
    Resource.record_timestamps = true
    
    redirect_to class_room_resource_page_section_resource_path(@class_room, @resource_page, @section, @resource) 
  end
  
  def change_order
    #make sure we don't update updated_at when just changing order or publishing
    Resource.record_timestamps = false
    
    get_path_vars
    @resource = Resource.find(params[:id])
    section = Section.find(params[:section][:id])
    new_order = params[:resource][:order].to_i
    old_order = @resource.order
    old_sec = @resource.section
    old_sec_recs = old_sec.resources.sort_by { |rec| rec.order }
    new_sec_recs = section.resources.sort_by { |rec| rec.order }
    
    if old_sec.id == section.id #stays in same section
      old_sec_recs.delete_at(old_order)
      if new_order >= old_sec_recs.length
        new_order = old_sec_recs.length
      end
      old_sec_recs.insert(new_order, @resource)
      old_sec_recs.each_with_index do |rec, i|
        rec.update_attribute(:order, i)
      end
    else
      old_sec_recs.delete_at(old_order)
      if new_order >= new_sec_recs.length
        new_order = new_sec_recs.length
      end
      new_sec_recs.insert(new_order, @resource)
      old_sec_recs.each_with_index do |rec, i|
        rec.update_attribute(:order, i)
      end
      @resource.update_attribute(:section_id, section.id)
      new_sec_recs.each_with_index do |rec, i|
        rec.update_attribute(:order, i)
      end
    end

    #Turn timestamps back on    
    Resource.record_timestamps = true
    
    redirect_to class_room_resource_page_path(@class_room, @resource_page)
        
  end
  
  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end
end
