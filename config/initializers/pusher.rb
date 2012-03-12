# This is configuration for Pusher.io
require "pusher"

PUSHER = YAML.load_file("#{Rails.root.to_s}/config/pusher.yml")[Rails.env]

if Rails.env!="production"
	Pusher.app_id = PUSHER["app_id"]
	Pusher.key = PUSHER["key"]
	Pusher.secret = PUSHER["secret"]
end