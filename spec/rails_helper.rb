require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  track_files 'lib/**/*.rb'
  add_filter '/spec/'
  command_name ENV.fetch('BUNDLE_GEMFILE', 'rspec')
end

require 'combustion'
require 'capybara/rspec'
require 'selenium-webdriver'

require_relative 'support/screenshot'
Capybara.javascript_driver = :selenium_chrome_headless

require 'best_in_place'

Combustion.initialize! :active_record, :action_controller, :action_view, :sprockets do
  config.assets.compile = true
  config.assets.compress = false
  config.assets.debug = false
  config.assets.digest = false
end

require 'rspec/rails'
require 'capybara/rails'
require 'best_in_place/test_helpers'

RSpec.configure do |config|
  config.include BestInPlace::TestHelpers
  config.use_transactional_fixtures = false
  config.raise_errors_for_deprecations!
  config.example_status_persistence_file_path = "failifier.txt"

  config.before do
    [TestResult, User, Cuca::Car].each(&:delete_all)
  end

  config.after(:each, js: true) do |example|
    if example.exception
      report_name = File.basename(ENV.fetch('BUNDLE_GEMFILE', 'Gemfile'), '.gemfile')
      filename = example.id.gsub(/[^a-zA-Z0-9_-]/, '_')
      path = File.expand_path("../tmp/screenshots/#{report_name}/#{filename}.png", __dir__)
      begin
        screenshot(path, open: false)
      rescue StandardError => error
        warn "Unable to save failure screenshot: #{error.message}"
      end
    end
  end

  if ENV['CI']
    report_name = File.basename(ENV.fetch('BUNDLE_GEMFILE', 'Gemfile'), '.gemfile')
    config.add_formatter 'progress'
    config.add_formatter 'RspecJunitFormatter', File.expand_path("../tmp/test-results/#{report_name}.xml", __dir__)
  end

  config.filter_run focus: true unless ENV['CI']
  config.run_all_when_everything_filtered = true
end
