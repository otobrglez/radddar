
# By Oto Brglez - <oto.brglez@opalab.com> 

# database_cleaner: https://github.com/bmabey/database_cleaner

require 'rubygems'
require 'spork'
require 'spork/ext/ruby-debug'

Spork.prefork do

  ENV["RAILS_ENV"] ||= 'test'
 
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'database_cleaner'

  Spork.trap_class_method(Rails::Mongoid, :load_models)
  Spork.trap_method(Rails::Application::RoutesReloader, :reload!)

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.include FactoryGirl::Syntax::Methods
    # config.include HelperMethods
    config.include Mongoid::Matchers


    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    #config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    ## config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true

    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

  end

end

Spork.each_run do
  FactoryGirl.reload
  load "#{Rails.root}/config/routes.rb"
  Dir["#{Rails.root}/app/**/*.rb"].each {|f| load f}
  Dir["#{Rails.root}/lib/**/*.rb"].each {|f| load f}
end

