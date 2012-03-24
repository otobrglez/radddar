source 'https://rubygems.org'

gem 'rails', '3.2.1'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

gem 'pusher', :git => 'git://github.com/pusher/pusher-gem.git'
gem 'em-http-request'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

gem 'haml', '>= 3.0.0'
gem 'haml-rails'
gem 'sass'
gem 'bson_ext'	# , '1.6.1'
gem 'mongoid'	#, :git => 'git://github.com/mongoid/mongoid.git'

gem 'omniauth', :git => 'git://github.com/intridea/omniauth.git', :tag => 'v1.0.2'
gem 'omniauth-facebook'
gem 'omniauth-twitter'
gem 'rabl'
gem 'pry-rails', :group => :development
gem 'jammit-s3', :group => :development

gem 'airbrake'

group :development, :test do
	gem 'rspec'
	gem 'rspec-rails'
	gem 'fuubar'
	
	gem 'guard'
	gem 'guard-rspec'
	gem 'guard-livereload'
	gem 'guard-spork'

	gem 'spork', '~> 1.0rc'
	gem 'growl'
 	gem 'spork-rails'

 	gem 'guard-livereload'
 	# gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
	
	#gem 'jasmine'
	#gem 'jasminerice'
	
	gem 'database_cleaner'
	gem 'pry'
	gem 'pry-doc'
	gem 'ruby-debug19', :require => 'ruby-debug'
	
	gem 'factory_girl_rails'
end
