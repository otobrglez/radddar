require "spec_helper"

describe ReminderMailer do
  
	let(:reminder_mailer) { ReminderMailer }
	let(:reminder){
		r = Reminder.new
		r.email = "otobrglez@gmail.com"
		r
	}

	it "sends email for 'new_reminder' " do
		mail = reminder_mailer.new_reminder(reminder)
		mail.subject.should =~ /guest/i
		mail.from.first.should =~ /info/
		mail.to.first.should =~ /info/

		mail.body.should =~ /otobrglez/
		mail.body.should =~ /RADDDAR/
	end

	it "sends email to say 'thanks_for_signup'" do
		mail = reminder_mailer.thanks_for_signup(reminder)
		mail.subject.should =~ /radddar/i
		mail.to.first.should == reminder.email
		mail.body.should =~ /thanks/i
	end
end
