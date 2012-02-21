class SessionsController < ApplicationController


  def auth
	  request.env['omniauth.auth']
  end
  
  def callback
    auth 

    render :json => auth.to_json
  end


end