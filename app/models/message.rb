class Message
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :from, :type => String
  field :to, :type => String
  field :body, :type => String

  field :from_to_stamp, :type => String
  index "from_to_stamp"

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'

  validates_presence_of :sender,
  	:recipient
  
  validates_length_of :body, :minimum => 1, :maximum => 140,
  	:message => "Message must be between 1 and 140 characters long!"

  before_create :build_channel
  after_save :dispatch_message

  def human_time
    today = DateTime.now
    if self.created_at.year == today.year &&
      self.created_at.month == today.month &&
      self.created_at.day == today.day
      self.created_at.strftime("%H:%M")
    else
      self.created_at.strftime("%d.%m %H:%M")
    end   
  end

  def from_to
    "#{self.from}-#{self.to}"
  end

  def to_s 
    "#{self.from_to}-#{self.created_at.to_i}"
  end

 # private
  	def build_channel # to(me) - from
  		self.from = self.sender_id.to_s   if self.from.nil?
  		self.to = self.recipient_id.to_s  if self.to.nil?
      self.from_to_stamp = "#{self.from}-#{self.to}"
  	end

    def dispatch_message
      # sender.trigger_event "message-sent", self
      recipient.trigger_event "message-received", {
        human_time: self.human_time,
        from_to_stamp: self.from_to_stamp,
        sender: self.from,
        to: self.to,
        body: self.body
      }
    end
end
