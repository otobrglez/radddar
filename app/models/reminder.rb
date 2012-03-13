require 'active_model'

class Reminder

	include ActiveModel::Conversion
  	include ActiveModel::Validations

	attr_accessor :email

	validates_presence_of :email
	validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/

	def to_s; "#{self.email}" end
	def persist; @persisted = true end
	def persisted?; @persisted end

	def sent=(value); @sent=value end
	def sent; @sent || false end
	def sent?; @sent end

end