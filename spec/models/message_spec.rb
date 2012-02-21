require 'spec_helper'

describe Message do

	let(:message){ Message.new }
	specify{
		message.should respond_to :from,
			:to,
			:sender,
			:recipient
	}

	let(:oto){ build :oto }
	let(:grega){ build :grega }

	it "can be sent" do
		message.should_not be_valid
		
		message.should have(1).error_on :sender
		message.should have(1).error_on :recipient
		message.should have(1).error_on :body

		message.sender = oto
		message.recipient = grega
		message.body = "Test from Oto to Grega"

		message.should be_valid
	end

	it "has some factories" do
		msg = build :message
		msg.sender.to_s.should match /oto/i
		msg.recipient.to_s.should match /grega/i
	end

end
