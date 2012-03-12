require "spec_helper"

describe "Testing configuration and some pusher" do
	
	it "should get some configuration" do
		PUSHER.should_not be_nil
		PUSHER["app_id"].should_not be_nil
	end

end