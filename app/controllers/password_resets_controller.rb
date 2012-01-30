class PasswordResetsController < ApplicationController

	before_filter :load_user_using_perishable_token, :only => [:edit, :update]  

	def new  
		require_no_user
	end  
		
	def create  
		@user = User.find_by_email(params[:email])  
		if @user  
			@user.deliver_password_reset_instructions!  
			flash[:notice] = "Instructions to reset your password have been emailed to you. " +  
			"Please check your email."  
			render 'home/please_reset_password', :layout => "application"
		else  
			flash[:notice] = "No user was found with that email address"  
			render :action => :new  
		end  
	end
	

		
	def edit  
	  @token = params[:id]
	end  
		
	def update  
		@user.password = params[:user][:password]  
		@user.password_confirmation = params[:user][:password_confirmation]  
		if @user.save  
			flash[:fail] = "Password successfully updated"  
			redirect_to user_path(@user)
		else  
		  render :action => :edit  
		end  
	end  
		
	private  
		def load_user_using_perishable_token  
			@user = User.find_using_perishable_token(params[:id])  
			unless @user  
				flash[:fail] = "We're sorry, but we could not locate your account. " +  
				"If you are having issues try restarting the " +  
				"reset password process."  
			  redirect_to root_url  
		  end  
		end
			
end  
