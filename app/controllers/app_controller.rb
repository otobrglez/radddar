class AppController < ApplicationController

	respond_to :html, :only => [:app, :landing]
  respond_to :js, :json

	layout 'app'

	before_filter :check_user_auth, :except => [:landing]

	# Landing page
	def landing
		return redirect_to(app_url) if signed_in?
		render :landing, :layout => false
  end

	# The app
	def app 

	end

  # Return user
  def profile
    respond_with(User.find(params[:id]))
  end

  # Retuns current user
  def current_user_action
    respond_with(current_user)
  end

  # Profile update
  def profile_update
    # TODO sex change trigger swap
    current_user.update_attributes(params[:user])
    current_user.save if current_user.valid?
    return render :json => current_user.to_json
  end

  # Status form
  def status_form
    respond_with(current_user) do |f|
      f.js { render "app/user/status_form" }
    end
  end

  # Get status
  def status_reload
    respond_with(current_user) do |f|
      f.js { render "app/user/status_reload" }
    end
  end

  # Set status
  def status_set
    current_user.update_attributes(params[:user])
    
    if current_user.valid?
      current_user.save
      return render "app/user/status_reload"
    end

    respond_with(current_user) do |f|
      f.js { render "app/user/status_form" }
    end
  end

	private
		# Make sure user is signed in!
		def check_user_auth
			return redirect_to(root_url, :notice => "Please sign in!") if not signed_in?
		end

end
