source 'https://rubygems.org'

# Specify your gem's dependencies in guard-chef.gemspec
if ENV['USE_INSTALLED_GUARD_CHEF'] == '1'
  gem 'guard-chef'
  gem 'launchy'
else
  gemspec
end

group :test do
  gem 'coveralls', require: false
end

group :development do
  gem 'rspec', '~> 3.3'
  gem 'rubocop', require: false
  gem 'guard-rspec', require: false
  gem 'rb-fsevent', require: false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-compat', '>= 0.0.2', require: false
  gem 'colorize', require: false
  gem 'pry', require: false
  gem 'pry-theme', require: false
  gem 'parser', '>= 2.2.2.5', '< 3.0'
  gem 'overcommit', require: false
  gem 'ruby-lint', require: false, path: '/Users/morgan/projects/ruby/oss-forks/ruby-lint'
  gem 'rubycritic', require: false
end

group :tool do
  gem 'ruby_gntp', require: false
end
