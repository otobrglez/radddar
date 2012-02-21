source 'https://rubygems.org'

gem 'rails', '3.2.1'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

gem 'haml', '>= 3.0.0'
gem 'haml-rails'
gem 'sass'

gem 'bson_ext'
gem 'mongoid' # , '>= 2.0.0.beta.19'
gem 'omniauth', :git => 'git://github.com/intridea/omniauth.git', :tag => 'v1.0.2'
gem 'omniauth-facebook'
gem 'omniauth-twitter'

group :development, :test do
	gem 'rspec'
	gem 'rspec-rails'
	
	gem 'guard'
	gem 'guard-rspec'

	gem 'spork', '~> 1.0rc'
	gem 'growl'
  	gem 'spork-rails'
 	gem 'guard-spork'
 	gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
	gem 'guard-livereload'

	#gem 'jasmine'
	#gem 'jasminerice'
	
	gem 'database_cleaner'
	gem 'pry'
	gem 'pry-doc'
	gem 'ruby-debug19', :require => 'ruby-debug'
	
	gem 'factory_girl_rails'
end
