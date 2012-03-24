# For more special queries please read:
# http://stackoverflow.com/questions/7702244/mongodb-with-mongoid-in-rails-geospatial-indexing

Mongoid.autocreate_indexes = true

class User
  include Mongoid::Document
  include Mongoid::Timestamps

  extend ActiveSupport::Concern
  include ActionView::Helpers::NumberHelper

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
	  User.allowed_swap_ranges.last
  }

  # Field status
  field :status, type: String

  # Allowed swap ranges for #swap_range
  def self.allowed_swap_ranges
  	[200, 1000, 20000, 200000] #m
  end

  # Return name as string
  define_method(:to_s) {
    age==0? "#{self.name}": "#{self.name}, #{age}"
  }

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
  	:message => "can't be longer than 140 characters!"
  
  validates_inclusion_of :swap_range,
  	:in => User.allowed_swap_ranges,
  	:message => "range is not allowed!"

#  included do
#      self.send(:distance)
#      self.send(:distance_to_human)
#  end

  # Distance from origin point
  def distance
    return 0 if self.loc == @@current_loc
    return 0 if self.loc.nil? or @@current_loc.nil?
    haversine_distance(@@current_loc,self.loc)
  end

  # Distance in human words
  def distance_to_human
    number_to_human(distance.to_i,:units => :distance_short).to_s
  end

  def distance_between user
    return 0 if self.loc == user.loc
    haversine_distance(self.loc, user.loc)
  end

  def distance_between_to_human user
    number_to_human(distance_between(user).to_i,:units => :distance_short).to_s
  end

  # Swap around user
  @@current_loc = nil
  def swap range=nil #m
  	range = self.swap_range unless !range.nil?

  	raise "Range: #{range} - is not allowed range!" unless range.in? User.allowed_swap_ranges

  	@@current_loc=self.loc

    self.send(:distance)
    self.send(:distance_to_human)

    User.where(:loc => {
    "$within" => {
        "$centerSphere" => [self.loc, ((range.fdiv(1000)).fdiv(6371))]
      }
    }).where(:updated_at.gt => 1.days.ago) # 24h!
  end

  # Convert gender hash into words
  def self.stat_to_human stats
    return "Nobody is around you." if stats[:none]==0 and stats[:male] == 0 and stats[:female] == 0
      
    pom_str = []
    stats = stats.select {|v| stats[v]>0 }

    stats.keys.each do |key|
      pom_str<< "#{stats[key]} #{User.none_to_ufo(key)}" if stats[key] == 1
      pom_str<< "#{stats[key]} #{User.none_to_ufo(key.to_s).pluralize}" if stats[key] > 1
    end

    pom_str_v = pom_str.join(" and ")

    are_is = "are"
    are_is = "is" if pom_str.size == 1 or stats.first[1] == 1
    are_is = "are" if stats.first[1] > 1

    out = "There #{are_is} #{pom_str_v} around you."
    
    m = out.scan(/(\ and\ \d+\ \w+)/i).flatten.compact.uniq  
    
    out.gsub! m.first, m.first.gsub(" and",",") if m.size > 1 
    
    out 
  end

  # Do the stat lookup
  def swap_stat range=nil
    users = self.swap(range).select {|u| u.id != self.id}
    stats = {female: 0,male: 0,none: 0}

    stats.keys.each do |key|
      stats[key] = users.to_a.inject(0) do |sum,v|
        s_key = key.to_s
        s_key = nil if key.to_s=="none"
        if v.gender==s_key
          sum + 1
        else
          sum + 0
        end
      end
    end

    User.stat_to_human stats
  end

  def self.none_to_ufo(value)
    return "UFO" if value.to_s == "none"
    value
  end

  # See chat with someone
  def chat_with user, limit=20
    from_to_stamp = ["#{self.id}-#{user.id}","#{user.id}-#{self.id}"]
    Message.where(:from_to_stamp.in => from_to_stamp).order_by([:created_at,:desc]).limit(limit)
  end

  # List of chats
  def chats
    # Find message exchanges
    message_pairs = Message.where('$or' => [{"sender_id" => self.id},{"recipient_id" => self.id}],
        :created_at.gt=>7.days.ago).order_by([:created_at,:asc]).distinct(:from_to_stamp).to_a.map! do |msg|
          msg.gsub(self.id.to_s,"").gsub(/\-/,"")
        end.uniq

    # Find responding users
    unless message_pairs.empty?
      # Users must be in range
      users = User.where(:_id.in => message_pairs).where(:loc => {"$within" => {
        "$centerSphere" => [self.loc,((self.swap_range.fdiv(1000)).fdiv(6371))
      ]}})

      # Map last_message to each user
      return users.map do |user|
        user.define_singleton_method :last_message do
          Message.first(conditions: {'$or' =>
            [{"sender_id" => self.id},{"recipient_id" => self.id}]},
            sort:[[:created_at,:asc]])
        end
        user
      end.sort_by!(&:last_message).reverse!
    end

    # Empty
    []
  end

  def remove_chat recipient

  
  end

  # Calculate channels
  def chats_OLD
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

    # "$centerSphere" => [self.loc, ((range.fdiv(1000)).fdiv(6371))]


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
    value=nil if value.nil? or value=="" or value=="none"
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

  # Big image of user profile
  def big_image
    return image.gsub(/square/i, "large") if image =~ /facebook/ && image =~ /square/
    return image.gsub(/normal/i, "original") if image =~ /twitter/ && image =~ /normal/
    image
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

  # Set birthday to 1.1.year
  def age= value
    value = DateTime.now.year-value.to_i
    self.birthday=DateTime.strptime("#{value}-1-1", "%Y-%m-%d")
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
    current_location = nil

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

      # If provider has location
      if !auth["info"].nil? && !auth["info"]["location"].nil?
        begin
          current_location = Geo.address_to_location(auth["info"]["location"])[:loc]
        rescue
          current_location = nil
        end
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

    user.loc = current_location unless current_location.nil?

    #TODO: update token for provider!

    if user.valid?
      user.updated_at = DateTime.now
      user.save
      user.trigger_swap_event "status-update_swap", user
    end

    user
  end

  def gender_str
    return "none" if self.gender.nil? or self.gender == "none"
    self.gender
  end

  # user #to_json
  def to_json options={}
    {
      id: id,
      name: name,
      image: image,
      birthday: birthday,
      age: age,
      gender: gender,
      loc: loc,
      swap_range: swap_range,
      status: status,
      updated_at: updated_at,
      providers: providers.map(&:provider),
      distance: distance,
      private_channel: private_channel,
      to_s: to_s
    }.to_json
  end

  def to_data
      data = {
        id: id,
        name: name,
        to_s: to_s,
        image: image,      
        #birthday: birthday,
        #age: age,
        gender: gender_str,
        loc: loc,
        swap_range: swap_range,
        #status: status,
        #updated_at: updated_at
      }

      Hash[(data.map{|i,v| "data-#{i}"}).zip(data.map{|i,v| v})]
  end

  # Name of private channel
  def private_channel
    "private-#{id}"
  end

  # Trigger pusher event
  def trigger_event event, data=nil
    Pusher[private_channel].trigger!(event, data)
  end

  # Trigger event for someone
  def trigger_event_for_user user, event, data=nil
    Pusher[user.private_channel].trigger!(event,data)
  end

  # Swap event
  def trigger_swap_event event, data=nil
    users = self.swap
    unless users.empty?
      users.each do |user|
        Pusher[user.private_channel].trigger!(event,data)
      end
    end
  end

  # Do the notification of user to user
  def notify user
    if self.can_notify? user
      note = Note.new(:from => self, :to => user)
      
      if note.valid?
        note.save 
        trigger_event_for_user user, "notification-received", note
        trigger_event "notification-sent", note
        
        return true
      end

      return false
    end

    false
  end

  # Can I notify this user?
  def can_notify? user
    return false if self.id == user.id
    not notification_exists? user
  end

  # Does notification exists
  def notification_exists? user
    a = Note.exists?(:conditions => {:from_id => self.id, :to_id => user.id})
    b = Note.exists?(:conditions => {:from_id => user.id, :to_id => self.id})
    a or b
  end

  # This is users feed (under chat!)
  def feed

    out = {
      chats: [],
      notes: []
    }

    users = self.swap.to_a

    out[:chats] = self.chats

    unless users.empty?

      users.each do |user|
        if user.id != self.id # Swap returs itself also!
          # Find notification that are pointed to user
          note = Note.first(conditions: {:to_id => self.id, :from_id => user.id})
          out[:notes] << note unless note.nil?
        end
      end

      # Fix order
      unless out[:notes].empty?
        out[:notes].sort_by!(&:created_at).reverse!

        out[:notes].map! do |note|
          found_user = users.select{ |user_p| user_p.id == note.from_id }.first
        
          unless found_user.nil?
            found_user.define_singleton_method :notified_at do
              note.created_at 
            end
            found_user.define_singleton_method :stamp do
              note.stamp
            end
          end

          found_user
        end
      end
    end

    out
  end

  # PI = 3.1415926535
  RAD_PER_DEG = 0.017453293   # PI/180
  # Rmiles = 3956             # radius of the great circle in miles
  Rkm = 6371                  # radius in kilometers...some algorithms use 6367
  # Rfeet = Rmiles * 5282     # radius in feet
  Rmeters = Rkm * 1000        # radius in meters

  # haversine
  def haversine_distance(a=[0,0],b=[0,0])
    lat1,lon1=a[0],a[1]
    lat2,lon2=b[0],b[1] 

    dlon = lon2 - lon1
    dlat = lat2 - lat1
    dlon_rad = dlon * RAD_PER_DEG
    dlat_rad = dlat * RAD_PER_DEG
    lat1_rad = lat1 * RAD_PER_DEG
    lon1_rad = lon1 * RAD_PER_DEG
    lat2_rad = lat2 * RAD_PER_DEG
    lon2_rad = lon2 * RAD_PER_DEG

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math.asin( Math.sqrt(a))

    Rmeters * c     # delta in meters
  end
end
