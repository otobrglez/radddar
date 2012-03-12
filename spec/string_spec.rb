require "spec_helper"

describe String do

	it "should respond to stat_to_human" do
	
		"test".should respond_to :stat_to_human
	
	end

	it "should do some magic with user" do
		out = User.stat_to_human({male:10,female:10,none:10})
		out.should == "There are 10 males, 10 females and 10 UFOs around you."

		out.stat_to_human.should ==
			"There are <span class=\"b\">10 males</span>, <span class=\"b\">10 females</span> and <span class=\"b\">10 UFOs</span> around you."

		User.stat_to_human({male:0,female:0,none:0}).stat_to_human.should =~ /(class)|(nobody)/
	end

end