require 'spec_helper'

describe Geo do

	it "should return my location" do
		loc = Geo.address_to_location "Miklavceva 16, 2000 Maribor"
		loc[:address].should match /Maribor/
		loc[:loc].should == [46.5580334, 15.614261]
	end

	it "should fail if you insert strange address" do
		expect {
			loc = Geo.address_to_location "lllaadasdasd"
		}.to raise_error RuntimeError
	end

end