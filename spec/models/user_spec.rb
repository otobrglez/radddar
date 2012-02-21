require 'spec_helper'
require "json"

describe User do

	let(:user) { User.new }
	
	specify{ user.should respond_to :name }
	
	specify{ user.should respond_to :swap_range }

	specify{ user.should respond_to :status }

	specify{ user.swap_range.should == 200}

	it "users factories" do
		user_x = build(:oto)
		user_x.name.should_not be_nil
	end

	it "#to_s returns name" do
		user.name = "Oto"
		user.to_s.should == "Oto"
	end

	it "has #loc" do
		user.should respond_to :loc
		user.loc = [100,100]
		user.loc.should == [100,100]
	end

	it "should respond_to updated_at" do
		user.should respond_to :updated_at
		user.should respond_to :created_at
	end

	it "has status that is no longer than 140 characters" do
		us = ""
		150.downto(0) { us << "a" }
		user.status = us

		user.should be_invalid
		user.should have(1).errors_on(:status)

		user.status = nil
		user.should be_valid
	end

	it "allows only ranged scopes" do
		User.should respond_to :allowed_swap_ranges
		User.allowed_swap_ranges.size.should == 4

		user.swap_range = 1233
		user.should be_invalid
		user.should have(1).error_on(:swap_range)

		user.swap_range = User.allowed_swap_ranges.first
		user.should be_valid
	end

	it "has default gender as none" do
		user.gender.should == "none"
	end

	context "finding nearest folks" do
		let(:oto){ build :oto }
		let(:miha){ build :miha }
		let(:grega){ build :grega }
		let(:ana){ build :ana }
		let(:john){ build :john }
		let(:folks){ [oto,miha,grega] }
		let(:all_folks){ [oto,miha,grega,ana,john] }

		before :each do
			all_folks.map(&:save)
			all_folks.size.should == 5
			User.all.to_a.size.should == 5
		end

		it "should return nearest folks" do
			oto.should respond_to :swap

			# 200 m
			oto.swap.to_a.should == [oto,miha]

			# 1km
			oto.swap(1000).to_a.should == [oto,miha,grega]

			# 200 km
			oto.swap(200*1000).to_a.should == [oto,miha,grega,ana]

			# 200 m
			john.swap.to_a.should == [john]
		end

		it "should ignore records older than 7 days" do
			ana.updated_at = 14.days.ago
			ana.save

			pa = User.where({:name => "Ana"}).first
			pa.name.should == "Ana"

			oto.swap(200*1000).to_a.should == [oto,miha,grega]
		end

		it "should brake swap if its out of range" do
			expect{
				oto.swap(123)

			}.to raise_error(RuntimeError)
		end

		it "has #box scope" do
			dejan = create :dejan
			User.all.to_a.size.should == 6
			User.should respond_to :box

			ana.updated_at = 14.days.ago
			ana.save
			
			User.box(oto.loc, ana.loc).to_a.should =~ [oto,miha]
		end
	end

	context "chat" do

		before do
			@oto = build :oto
			@miha = build :miha
			@grega = build :grega
			@john = build :john

			users = [@oto,@miha,@grega,@john]
			users.map(&:save)
		end

		it "user should have channels" do
			
			@oto.should respond_to :chats
			@oto.chats.to_a.should == []

			# oto -> miha
			m1 = Message.new :sender => @oto, :recipient => @miha, :body => "oto 2 miha",
				:created_at => 1.hour.ago

			# miha -> oto
			m2 = Message.new :sender => @miha, :recipient => @oto, :body => "miha 2 oto",
				:created_at => 30.minutes.ago
			
			# oto -> miha
			m3 = Message.new :sender => @oto, :recipient => @miha, :body => "oto 2 miha",
				:created_at => 20.minutes.ago

			# grega -> oto
			m4 = Message.new :sender => @grega, :recipient => @oto, :body => "grega 2 oto",
				:created_at => 30.days.ago

			# grega -> miha
			m5 = Message.new :sender => @grega, :recipient => @miha, :body => "grega 2 miha",
				:created_at => 2.days.ago

			# oto -> grega
			m6 = Message.new :sender => @oto, :recipient => @grega, :body => "oto 2 grega",
				:created_at => 1.hour.ago

			[m1,m2,m3,m4,m5,m6].map(&:save).should == [true,true,true,true,true,true]

			chats = @oto.chats
			
			chats.to_a.should_not be_empty
			
		end

		def msg sender, recipient, body="Msg..", created_at=DateTime.now
			m = Message.new :sender => sender, :recipient=> recipient, :body=>body, :created_at=>created_at
			raise "Not ql." unless m.valid?
			m.save
		end

		it "has some another chat things" do
			Message.all.to_a.size.should == 0

			@oto.swap_range = 1000
			@oto.save

			msg @oto, @miha
			msg @oto, @miha, 1.hours.ago
			msg @miha, @oto, 2.hours.ago
			msg @miha, @oto, 3.hours.ago

			@oto.chats.should == [@miha]

			msg @grega, @oto, 7.hours.ago
			msg @oto, @grega, 8.hours.ago

			@oto.chats.should =~ [@miha,@grega]
			@oto.chats.first["inside_swap"].should be_true

			msg @oto, @john, 3.hours.ago
			@oto.chats.last["inside_swap"].should == false

		end

	end

	context "omniauth integration" do

		def read_json file_name
			JSON.parse(File.read(Rails.root.join("spec","factories",file_name)))
		end

		let(:facebook_otobrglez){ read_json "facebook_otobrglez.json" }
		let(:twitter_otobrglez){ read_json "twitter_otobrglez.json" }

		it "gets name from auth " do
			User.name_from_provider(facebook_otobrglez).should == 'oto.brglez'
			User.name_from_provider(twitter_otobrglez).should == 'otobrglez'
		end

		it "supports facebook provider" do
			facebook_otobrglez["provider"] =~ /facebook/
			twitter_otobrglez["provider"] =~ /twitter/

			twitter_otobrglez["info"]["nickname"] =~ /otobrglez/
			facebook_otobrglez["info"]["nickname"] =~ /oto\.brglez/

			user = User.find_or_create facebook_otobrglez
			user.name.should =~ /oto\.brglez/
			
			# Image is taken from providers if not set
			user.image.should =~ /graph\.facebook/i
			user.image="dddd"
			user.image.should == "dddd"

			# Birthday 
			user.birthday.year.should equal 1987
			user.age.should equal DateTime.now.year - user.birthday.year

			user.to_s.should == "oto.brglez, 25"

			# Gender
			facebook_otobrglez["extra"]["raw_info"]["gender"].should == "male"

			user.gender.should == 'male'
			user.gender= 'female'
			user.gender.should == 'female'

			# Providers array must be appended
			user.providers.should_not be_empty
		end

		it "supports twitter provider" do
			user = User.find_or_create twitter_otobrglez
			user.name.should =~ /otobrglez/
			user.age.should == 0
		end
	end
end
