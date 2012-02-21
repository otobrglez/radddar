# For more special queries please read:
# http://stackoverflow.com/questions/7702244/mongodb-with-mongoid-in-rails-geospatial-indexing

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # First name if facebook / username if twitter
  field :name, :type => String

  # This field are from providers if they are not set
  field :image_custom, :type => String
  field :birthday_custom, :type => Date
  field :gender_custom, type: String, default: -> { "none" }

  # loc holds last location that user provided
  field :loc, type: Array
  index [[ :loc, Mongo::GEO2D ]]

  # Range of my swap (200m default)
  field :swap_range, type: Integer, default: -> {
	  User.allowed_swap_ranges.first
  }

  # Field status
  field :status, type: String

  # Allowed swap ranges for #swap_range
  def self.allowed_swap_ranges
  	[200, 1000, 20000, 200000] #m
  end

  # Return name as string
  define_method(:to_s) { "#{self.name}" }

  scope :box, ->(loc_a, loc_b) {
	  User.where(:loc => {
		  "$within" => {
			  "$box" => [
				  loc_b, loc_a
			  ]
			}
		}).where(:updated_at.gt => 7.days.ago)
	}

  embeds_many :providers

  validates_length_of :status, :maximum => 140,
  	:allow_nil => true,
  	:allow_blank => true,
  	:message => "Status can't be longer than 140 characters!"
  
  validates_inclusion_of :swap_range,
  	:in => User.allowed_swap_ranges,
  	:message => "Selected range is not allowed!"

  # Swap around user
  def swap range=nil #m
  	range = self.swap_range unless !range.nil?

  	raise "Range: #{range} - is not allowed range!" unless range.in? User.allowed_swap_ranges
  	
  	User.where(:loc => {
	  	"$within" => {
		  	"$centerSphere" => [
			  	self.loc,
			  	((range.fdiv(1000)).fdiv(6371))
			]
		}
	}).where(:updated_at.gt => 7.days.ago)
  end

  # Calculate channels
  def chats
  	# 1. Messages where current_user is sender or recipient
  	# 2. Grouped by recipent
  	senders = Message.any_of({sender_id: self.id},{recipient_id: self.id })
  		.where(:created_at.gt=> 7.days.ago)
	  	.asc(:created_at)
	  	.distinct(:recipient_id)
#	  	.only(:sender_id, :recipient_id)


  	# 3. Who is inside users swap
  	inside_sphere = User.where(:_id.in => senders).where(:loc => {
	  	"$within" => {
		  	"$centerSphere" => [
			  	self.loc,
			  	((self.swap_range.fdiv(1000)).fdiv(6371))
			]
		}
	  }).to_a.map(&:id)

  	# 4. Add inside_swap attribute to sender
  	senders.to_a.map do |sender|
  		sender = User.find(sender)

  		sender["inside_swap"] = false		
  		sender["inside_swap"] = true if sender.id.in? inside_sphere
  		
  		if sender.id == self.id
  			nil
  		else
  			sender
  		end

  	end.compact!

  end

  # Set name from nicname/name mess
  def self.name_from_provider auth
    if auth["provider"] == "facebook"
      if !auth["info"].nil? && !auth["info"]["nickname"].nil?
        auth["info"]["nickname"]
      elsif !auth["info"].nil? && !auth["info"]["first_name"].nil?
        auth["info"]["first_name"]
      else
        nil
      end
    elsif auth["provider"] == "twitter"
      if !auth["info"].nil? && !auth["info"]["nickname"].nil?
        auth["info"]["nickname"]
      else
        nil
      end
    else
      nil
    end
  end

  # Set custom image for user
  def image= value
    self.image_custom = value
    write_attribute :image_custom, value
  end

  # Set birthday
  def birthday= value
    self.birthday_custom = value
    write_attribute :birthday_custom, value
  end

  # Set gender
  def gender= value
    self.gender_custom = value
    write_attribute :gender_custom, value
  end

  # Get image for user from image_path if set otherwise from providers
  def image
    return self.image_custom unless self.image_custom.nil?
    return nil if self.providers.size == 0
    images = self.providers.map(&:image).compact
    return images.first if !images.empty?
    nil
  end

  # User birthday
  def birthday
    return self.birthday_custom unless self.birthday_custom.nil?
    return nil if self.providers.size == 0
    birthdays = self.providers.map(&:birthday).compact
    return birthdays.first if !birthdays.empty?
    nil
  end

  # User age
  def age
    return 0 if birthday.nil?
    DateTime.now.year-birthday.year
  end

  # Get gender for user
  def gender

    if self.providers.size == 0
      return self.gender_custom
    end

    if self.gender_custom != "none"
      return self.gender_custom
    end

    return nil if self.providers.size == 0
    genders = self.providers.map(&:gender).compact
    return genders.first if !genders.empty?
    nil    
  end

  # Find or create user from omniauth
  def self.find_or_create auth

    if auth["provider"] =~ /(facebook|twitter)/i
      provider = Provider.new(
        :provider => auth["provider"],
        :uid => auth["uid"],
        :name => User.name_from_provider(auth)
      )

      # If provider provides image
      if auth["provider"] == "facebook"
        if !auth["info"].nil? && !auth["info"]["image"].nil?
          provider.image = ["http://graph.facebook.com/",
            provider.uid,"/picture?type=square"].join('') #50x50
        end
      end

      if auth["provider"] == "twitter"
        if !auth["info"].nil? && !auth["info"]["image"].nil?
          provider.image = ["http://api.twitter.com/1/users/profile_image?screen_name=",
            provider.name, "&size=normal"].join('') #48x48
        end
      end

      # If provider provides birthday
      if !auth["extra"].nil? && !auth["extra"]["raw_info"].nil? && !auth["extra"]["raw_info"]["birthday"].nil?
        provider.birthday = Date.strptime(auth["extra"]["raw_info"]["birthday"],'%m/%d/%Y')
      end

      # If provider provides gender
      if !auth["extra"].nil? && !auth["extra"]["raw_info"].nil? && !auth["extra"]["raw_info"]["gender"].nil?
        provider.gender = auth["extra"]["raw_info"]["gender"]
      end

    else
      raise 'Provider #{auth["provider"]} - is not yet supported!'
    end

    # Find user that has provider
    user = User.first(conditions: {
      :"providers.uid" => provider.uid,
      :"providers.provider" => provider.provider})

    if user.nil?
      user = User.new(:name => provider.name)
      user.providers = [provider]
    end


    #TODO: update location from provider + Geo
    #TODO: update token for provider!

    user.save if user.valid?

    user
  end

end
