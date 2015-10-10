$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rspec'

if RUBY_ENGINE == 'rbx'
  $DEBUG = true
  require 'rspec/matchers'
  require 'rspec/matchers/built_in//be'
end

if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
end

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'guard/chef'

RSpec.configure do |config|
  config.expect_with :rspec do |ex|
    ex.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run focus: ENV['CI'] != 'true'
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
  config.raise_errors_for_deprecations!
end
