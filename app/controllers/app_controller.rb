class AppController < ApplicationController

	respond_to :html
	layout false

	def app
  		render :landing
  	end

  	def test
  		render :json => ENV.to_json
  	end

end
