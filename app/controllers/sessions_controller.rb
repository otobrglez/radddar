class SessionsController < ApplicationController

	protect_from_forgery :except => :pusher_auth

	# Access to auth hash from omniauth
	def auth
		request.env['omniauth.auth']
	end

	# Respond to OAuth callback
	def callback
		raise "Unknown provider #{params[:provider]}." unless params[:provider].in? %w(facebook twitter google_oauth2)
		user = User.find_or_create auth

####
=begin
	c_key = auth["extra"]["access_token"].consumer.key
	c_secret = auth["extra"]["access_token"].consumer.secret
	secret = auth["extra"]["access_token"].secret
	token = auth["extra"]["access_token"].token
=end
####
		session[:user_id]=user.id.to_s
		redirect_to(app_url, :notice => "Signed in!")
	end

	# Sigout
	def destroy
 		session[:user_id] = nil
  		redirect_to root_url, :notice => "Signed out!"
	end

	# Auth for pusher
	def pusher_auth
		if signed_in?
			response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
				:user_id => current_user.id, # => required
				:user => current_user
			})
      		render :json => response
	    else
	      render :text => "Not authorized", :status => '403'
	    end
	end
end

