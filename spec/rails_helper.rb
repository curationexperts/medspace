# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rails/all'
require 'rake'
require 'rspec/rails'
require 'action_view'
require 'spec_helper'
require 'devise'
require 'devise/version'
require 'active_fedora/noid/rspec'
require 'rspec/matchers'
require 'active_fedora/cleaner'
require 'capybara/rspec'
require 'capybara/rails'
require 'database_cleaner'

# Require support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

# See https://github.com/thoughtbot/shoulda-matchers#rspec
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  config.before :suite do
    ActiveFedora::Cleaner.clean!
    Rails.application.load_tasks
    Rake::Task.define_task(:environment)
    Rake::Task['hyrax:default_admin_set:create'].invoke
  end

  config.before :each do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Capybara::RSpecMatchers, type: :input

  config.include Warden::Test::Helpers, type: :feature
  config.after(:each, type: :feature) { Warden.test_reset! }
  config.filter_run_excluding image_tests: true
  # Gets around a bug in RSpec where helper methods that are defined in views aren't
  # getting scoped correctly and RSpec returns "does not implement" errors. So we
  # can disable verify_partial_doubles if a particular test is giving us problems.
  # Ex:
  #   describe "problem test", verify_partial_doubles: false do
  #     ...
  #   end
  config.before :each do |example|
    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = example.metadata.fetch(:verify_partial_doubles, true)
    end
  end
end
