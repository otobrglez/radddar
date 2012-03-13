class ReminderMailer < ActionMailer::Base
  default from: "info@radddar.com",
  	subject: "RADDDAR - Who's on your?"

  def new_reminder(reminder)
  	@reminder = reminder
  	mail(to: "info@radddar.com", subject:"RADDDAR - New guest!" ) do |f|
  		f.text
  	end
  end

  def thanks_for_signup(reminder)
  	@reminder = reminder
  	mail(to: reminder.email) do |f|
  		f.text
  	end
  end

end
