class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end
  
  def new_ajax
	@user_session = UserSession.new
	render :action => :new, :layout => false
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default root_url
    elsif @user_session.attempted_record && !@user_session.invalid_password? && !@user_session.attempted_record.active?
      flash[:fail] = render_to_string(:partial => 'user_sessions/not_active.html.erb', :locals => { :user => @user_session.attempted_record }).html_safe
      redirect_to :action => :new
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default root_url
  end
end

