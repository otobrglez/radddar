class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :signed_in?

  before_filter :move_to_right

  def move_to_right
    if Rails.env == "production"
      if not ['www.radddar.com'].include? request.host
        redirect_to "http://www.radddar.com"
      end
    end
  end

	def current_user
		#begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    #rescue
    #  session[:user_id] = nil
    #  redirect_to root_path
    #end
	end

	def signed_in?
		not (session[:user_id].nil?)
	end
end
