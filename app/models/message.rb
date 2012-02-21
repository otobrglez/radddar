class Message
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :from, :type => String
  field :to, :type => String
  field :body, :type => String

  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'

  validates_presence_of :sender,
  	:recipient
  
  validates_length_of :body, :minimum => 1, :maximum => 140,
  	:message => "Message must be between 1 and 140 characters long!"

  before_create :build_channel

  private
  	def build_channel # to(me) - from
  		self.from = self.sender.to_s if self.from.nil?
  		self.to = self.recipient.to_s if self.to.nil?
  	end
end
