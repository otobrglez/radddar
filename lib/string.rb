String.class_eval do
	
	def stat_to_human klass="b"
		str = self.to_s

		founds = str.scan(/(\d+\ \w+)|(nobody)/ix)
		founds = founds.flatten.compact

		founds.each { |f|
			str.sub! f, "<span class=\"#{klass}\">#{f}</span>"
		}
		
		str
	end

end