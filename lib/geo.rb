require 'json'
require 'net/http'

module Geo

	# Convert adddress to location using Google Maps V3 API
	def self.address_to_location address
		begin
			address_e = URI.encode(address)
			url = "http://maps.google.com/maps/geo?q=#{address_e}&output=json&oe=utf8&sensor=false"
			result = JSON.parse(Net::HTTP.get_response(URI.parse(url)).body)
			raise "Wrong status" if result["Status"]["code"] != 200

			{
				loc: result["Placemark"].first["Point"]["coordinates"][0..1].reverse,
				address: result["Placemark"].first["address"]
			}
		rescue
			raise "Error getting location for address \"#{address}\".".strip
		end
	end

end