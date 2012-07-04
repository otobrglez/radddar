class NotificationsMailer < ActionMailer::Base
  default from: "info@radddar.com",
    subject: "RADDDAR - Who's on your?"

  def poke note
    @from, @to = note.from, note.to

    return false if @to.email == nil or @to.email == ""

    mail(to: @to.email, subject:"#{@from} poked you on RADDDAR!") do |f|
      f.text
    end
  end

  def new_chat
    @greeting = "Hi"
    mail to: "to@example.org"
  end
end
