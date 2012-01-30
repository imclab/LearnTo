class SubcommentsController < ApplicationController
  def new
    @subcomment = Subcomment.new
  end

  def create
    @subcomment = Subcomment.new(params[:subcomment])
    @subcomment.comment_id = params[:comment_id]
    @subcomment.user_id = current_user.id
    @post = @subcomment.comment.post
    @forum = @post.forum
    @class_room = @forum.class_room
        
    respond_to do |format|
       if @subcomment.save
        user_notification("new_subcomment","Subcomment",@subcomment.comment.user,@subcomment.id, @subcomment.comment.id)
        format.html  { redirect_to(@subcomment, :notice => 'Comment was successfully created.') }
        partial = render_to_string :partial => "subcomments/subcomment.html.haml", :locals => 
        {:subcomment => @subcomment, :comment => @subcomment.comment}
        format.json  { render :json => {:new_subcomment => partial} }
      else
        format.html  { redirect_to :back }
        format.json  { render :json => @subcomment.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @subcomment = Subcomment.find(params[:id])
    if @subcomment.user_id != current_user.id
      redirect_to root_url
    end
    @subcomment.destroy
    redirect_to :back
  end
end
