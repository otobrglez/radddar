require 'spec_helper'

describe Note do

	let(:note) { Note.new }
	let(:oto){ Factory.build :oto }

	it "has time" do
		note.should respond_to :created_at
	end

	it "is from user to user" do
		note.should respond_to :from
		note.should respond_to :to
	end

	it "should be able to send note from to" do
		note.should_not be_valid
		note.from = oto
		note.to = oto
		note.should be_valid
		
		note.to_s.should =~ /(\w+)-(\w+)-(\d)/
	end

	context "User has note" do

		let(:miha){ Factory.build :miha }

		it "should be w/ me " do
			oto.should_not be_nil
		end

		it "should respond to #notify" do
			oto.should respond_to :notify
			oto.should respond_to :can_notify?

			oto.can_notify?(oto).should == false
			oto.notify(oto).should == false

			oto.can_notify?(miha).should == true
			oto.notify(miha).should == true

			oto.can_notify?(miha).should == false
			oto.notify(miha).should == false
		end

	end

end
