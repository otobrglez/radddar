class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :signed_in?

  # private
  	def current_user
  		@current_user ||= User.find(session[:user_id]) if session[:user_id]
  	end

  	def signed_in?
  		not (session[:user_id].nil?)
  	end
end
