# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    sender { FactoryGirl.build :oto }
    recipient { FactoryGirl.build :grega }
    body "This is message from Oto to Grega"
  end

  factory :message_grega2oto_1, :parent => :message do
  	sender { FactoryGirl.build :grega }
  	recipient { FactoryGirl.build :oto }
  	body "AAA"
  end

  factory :message_grega2oto_2, :parent => :message do
	sender { FactoryGirl.build :grega }
	recipient { FactoryGirl.build :oto }
	body "BBB"
  end

  factory :message_miha2oto_2, :parent => :message do
  	sender { FactoryGirl.build :miha }
  	recipient { FactoryGirl.build :oto }
  end


end
