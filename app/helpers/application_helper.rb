module ApplicationHelper

	# Add some nice span-wraps 
	def humanize_stat stat
		if stat =~ /(\d+\ (\w+))/
			m = stat.scan /(\d+\ (\w+))/
			unless m.empty?
				m.each do |pair|
					stat.gsub! pair.first,
						content_tag(:span,pair.first,:class => pair.last.downcase.singularize)
				end
			end
		end

	 	raw stat
	end

	# Format message time
	def message_time message
		today = DateTime.now
		if message.created_at.year == today.year &&
		   message.created_at.month == today.month &&
		   message.created_at.day == today.day
			message.created_at.strftime("%H:%M")
		else
			message.created_at.strftime("%d.%m %H:%M")
		end
	end

end
