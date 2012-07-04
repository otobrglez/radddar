require "spec_helper"

describe NotificationsMailer do
  describe "poke" do
    let(:mail) { NotificationsMailer.poke }

    it "renders the headers" do
      mail.subject.should eq("Poke")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "new_chat" do
    let(:mail) { NotificationsMailer.new_chat }

    it "renders the headers" do
      mail.subject.should eq("New chat")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
