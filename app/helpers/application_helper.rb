module ApplicationHelper

	# Add some nice span-wraps 
	def humanize_stat stat
		if stat =~ /(\d\ (\w+))/
			m = stat.scan /(\d\ (\w+))/
			unless m.empty?
				m.each do |pair|
					stat.gsub! pair.first,
						content_tag(:span,pair.first,:class => pair.last.downcase.singularize)
				end
			end
		end

	 	raw stat
	end

end
