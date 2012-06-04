require 'spec_helper'
require "json"


# Dirty fix man :D
class User; def self.allowed_swap_ranges; [200, 1000, 20000, 200000] end end

describe User do

	# Test the monkey patch for testing
	it "has overriden swap ranges" do
		User.allowed_swap_ranges.should == [200, 1000, 20000, 200000]
	end

	let(:user) { User.new }
	
	specify{ user.should respond_to :name }
	
	specify{ user.should respond_to :swap_range }

	specify{ user.should respond_to :status }

	specify{ user.swap_range.should == User.allowed_swap_ranges.last}

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
			oto.swap(User.allowed_swap_ranges.first).to_a.should == [oto,miha]

			# 1km
			oto.swap(1000).to_a.should == [oto,miha,grega]

			# 200 km
			oto.swap(200*1000).to_a.should == [oto,miha,grega,ana]

			# 200 m
			john.swap.to_a.should == [john]
		end

		it "should do the textual swap" do
			swap = oto.swap(200*1000).to_a
			swap.should == [oto,miha,grega,ana]

			swap.last.gender.should == "female"
			swap.first.gender.should == "male"

			oto.should respond_to :swap_stat
			te = oto.swap_stat(200*1000)
			te.should =~ /2\ boys/ # not me
			te.should =~ /1\ girl/
		end

		it "also calculates distance from origin point" do
			list = oto.swap(200*1000).to_a
			list.should == [oto,miha,grega,ana]

			list.last.should respond_to :distance
			list.last.distance.should_not be_nil
			
			list[1].distance.should < list.last.distance

			list.last.should respond_to :distance_to_human
			list.last.distance_to_human.should =~ /(\d) km/
		end

		it "should be able to say distance from who" do
			list = oto.swap(200*1000).to_a
			list.should == [oto,miha,grega,ana]

			oto.should respond_to :distance_between
			distance = oto.distance_between(miha)
			distance.should_not be_nil		
			
			oto.should respond_to :distance_between_to_human
			oto.distance_between_to_human(miha).should =~ /\d m/
		end

		it "should ignore records older than 7 days" do
			ana.updated_at = 14.days.ago
			ana.save

			pa = User.where({:name => "Ana"}).first
			pa.name.should == "Ana"

			oto.swap(200*1000).to_a.should == [oto,miha,grega]
		end

		it "should tell us about sex ;) " do
			list = oto.swap(200*1000).to_a
			list.should == [oto,miha,grega,ana]

			test_stat = {
				female: 0,
				male: 0,
				none: 0
			}

			User.stat_to_human(test_stat).should == "Nobody is around you."

			User.stat_to_human(test_stat.merge({male:1})).should == "1 boy around you."
			User.stat_to_human(test_stat.merge({male:2})).should == "2 boys around you."
			User.stat_to_human(test_stat.merge({male:10})).should == "10 boys around you."

			User.stat_to_human(test_stat.merge({female:2})).should == "2 girls around you."
			
			User.stat_to_human(test_stat.merge({male:1,female:1})).should == "1 girl and 1 boy around you."
			User.stat_to_human(test_stat.merge({male:2,female:2})).should == "2 girls and 2 boys around you."
			
			User.stat_to_human(test_stat.merge({male:2,female:2,none:1})).should == "2 girls, 2 boys and 1 UFO around you."
			User.stat_to_human(test_stat.merge({male:2,female:2,none:2})).should == "2 girls, 2 boys and 2 UFOs around you."

			User.stat_to_human(test_stat.merge({male:10,female:10,none:10})).should == "10 girls, 10 boys and 10 UFOs around you."

=begin
			puts " "
			[0,1,10].each do |m|
				[0,1,10].each do |f|
					[0,1,10].each do |n|
						pom = User.stat_to_human({male:m,female:f,none:n})
						puts "\"#{m}\",\"#{f}\",\"#{n}\",\"#{pom}\""
					end
				end
			end
=end
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
			# @oto.chats.first["inside_swap"].should be_true

			msg @oto, @john, 3.hours.ago
			
			# @oto.chats.last["inside_swap"].should == false

		end

	end

	context "user feed" do

		let(:oto) { Factory.build :oto }
		let(:miha) { Factory.build :miha }
		let(:dejan){ Factory.build :dejan }

=begin
		it "should have feed" do

			oto.save
			miha.save
			dejan.save

			oto.should_not be_nil
			miha.should_not be_nil
			oto.swap.to_a.should =~ [oto,miha,dejan]
			miha.swap.to_a.should =~ [oto,miha,dejan]

			oto.should respond_to :feed

			otos_feed = oto.feed
			otos_feed[:chats].should be_empty
			otos_feed[:notes].should be_empty

			oto.notify(miha).should == true
			dejan.notify(miha).should == true

			oto.feed[:notes].size.should == 0
			dejan.feed[:notes].size.should == 0
			miha.feed[:notes].size.should == 2

			miha.feed[:notes].first.should == dejan
			miha.feed[:notes].first.should respond_to :notified_at, :stamp

			miha.feed[:notes].first.stamp =~ /(\w+)-(\w+)-(\d)/

			miha.feed[:notes].last.should == oto

			miha.notify(oto).should == false
		end
=end

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
			

			user.should respond_to :big_image
			user.big_image.should =~ /large/


			# Image is taken from providers if not set
			user.image.should =~ /graph\.facebook/i
			user.image="dddd"
			user.image.should == "dddd"

			# Birthday 
			#user.birthday.year.should equal 1987
			#user.age.should equal DateTime.now.year - user.birthday.year
			#user.to_s.should == "oto.brglez, 25"

			# Age
			user.should respond_to :age=
			user.age=10
			user.birthday.year.should == 2002

			# Gender
			facebook_otobrglez["extra"]["raw_info"]["gender"].should == "male"

			user.gender.should == 'male'
			user.gender= 'female'
			user.gender.should == 'female'

			# Providers array must be appended
			user.providers.should_not be_empty

			user.should respond_to :from_facebook?
			user.from_facebook?.should be_true


		end

		it "supports twitter provider" do
			user = User.find_or_create twitter_otobrglez
			user.name.should =~ /otobrglez/
			user.age.should == 0


			user.loc.should_not be_empty
		end

		it "supports repeted login" do
			user = User.find_or_create twitter_otobrglez
			user_2 = User.find_or_create twitter_otobrglez
			user.id.should == user_2.id
		end

		it "has nice #to_json" do
			user = User.find_or_create facebook_otobrglez
			string = user.to_json.to_s
			
			string.should match /oto\.brglez/

			hash = JSON.parse(string)

			hash.keys.should include "id"
			hash.keys.should include "name"
			hash.keys.should include "image"
			hash.keys.should include "birthday"
			hash.keys.should include "age"
			hash.keys.should include "loc"
			hash.keys.should include "swap_range"
			hash.keys.should include "status"
			hash.keys.should include "updated_at"

			hash.keys.should include "providers"
			hash.keys.should include "distance"

			hash.keys.should include "private_channel"
			hash["private_channel"].should =~ /private\-/
		end
	end
end
