source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: '.tool-versions'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1"

# For controlling access
gem 'rack-attack'

# Have added this for rails 8.1 support
gem 'cloudflare-rails', github: "modosc/cloudflare-rails", tag: "v7.0.0"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Postgres driver
gem 'pg'

# Use the Puma web server [https://github.com/puma/puma]
gem "puma"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add explictly now
gem "csv"
gem "irb"
gem "fiddle"

# Catch any errors and send them to James
gem "rollbar"

# For data migrations
gem "after_party"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
  gem "brakeman"
  gem "bundler-audit"
  gem "annotaterb"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "rspec-rails"
end
