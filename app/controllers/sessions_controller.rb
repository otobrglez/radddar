class SessionsController < ApplicationController

	# Access to auth hash from omniauth
	def auth
		request.env['omniauth.auth']
	end

	# Respond to OAuth callback
	def callback
		raise "Unknown provider #{prams[:provider]}." unless params[:provider].in? %w(facebook twitter)
		user = User.find_or_create auth
		session[:user_id]=user.id.to_s

		redirect_to(app_url, :notice => "Signed in!")
	end

	def destroy
 		session[:user_id] = nil
  		redirect_to root_url, :notice => "Signed out!"
	end


end