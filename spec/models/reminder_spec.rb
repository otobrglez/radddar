require "spec_helper"

describe Reminder do

	let(:reminder) { Reminder.new }
	specify{ reminder.should respond_to :email }

	it "has #to_s" do
		reminder.email = "otobrglez@gmail.com"
		reminder.should respond_to :to_s
		reminder.to_s.should =~ /otobrglez/
	end

	it "validates presence of email" do
		reminder.should_not be_valid
		reminder.errors.size.should == 2
		reminder.email = "otobrglez@gmail.com"
		reminder.should be_valid
	end

	it "has method #sent" do
		reminder.should respond_to :sent
		reminder.sent.should == false
		reminder.sent = true
		reminder.sent.should == true
		reminder.sent?.should == true
	end

end