class Note
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :from, :class_name => "User"
  belongs_to :to, :class_name => "User"

  validates_presence_of :from, :to

  def to_s; "#{self.from_id}-#{self.to_id}-#{created_at.to_i}" end

  def stamp; self.to_s end

  # Find note if you have message stamp
  def self.find_with_stamp stamp
  	if stamp =~ /(\w+)-(\w+)-(\d+)/
  		return Note.first(conditions: {
  			:from_id => Regexp.last_match[1],
  			:to_id => Regexp.last_match[2],
  			:created_at => Time.at(Regexp.last_match[3].to_i)
	  	})
  	end

  	nil
  end
end
