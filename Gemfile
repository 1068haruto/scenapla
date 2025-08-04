source "https://rubygems.org"

ruby "3.2.3"

gem "rails", "~> 7.2.1", ">= 7.2.1.1"
gem "sprockets-rails", "~> 3.5"     # The original asset pipeline for Rails
gem "pg", "~> 1.6"                  # Use postgresql as the database for Active Record
gem "puma", ">= 5.0"                # Use the Puma web server
gem "jsbundling-rails", "~> 1.3"    # Bundle and transpile JavaScript
gem "turbo-rails", "~> 2.0"         # Hotwire's SPA-like page accelerator
gem "stimulus-rails", "~> 1.3"      # Hotwire's modest JavaScript framework
gem "cssbundling-rails", "~> 1.4"   # Bundle and process CSS
gem "jbuilder", "~> 2.13"           # Build JSON APIs with ease

# gem "redis", ">= 4.0.1"　　　　　 　# Use Redis adapter to run Action Cable in production
# gem "kredis"                      # Use Kredis to get higher-level data types in Redis

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", "~> 1.2023", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18", require: false

# gem "image_processing", "~> 1.2"  # Use Active Storage variants

# user関連
gem "devise", "~> 4.9"

# auth認証関連
gem "omniauth", "~> 2.0"
gem "omniauth-google-oauth2", "~> 1.0"
gem "omniauth-rails_csrf_protection"

# グラフ表示関連
gem "chartkick", "~> 5.1"
gem "groupdate", "~> 6.5"

# news関連
gem "http", "~> 5.2"

# ai_advise関連
gem "ruby-openai", "~> 7.4"

group :development, :test do
  gem "debug", "~> 1.9", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", "~> 7.0", require: false  # Static analysis for security vulnerabilities
  gem "rubocop-rails-omakase", "~> 1.0", require: false  # Omakase Ruby styling

  # rubocop関連
  gem "rubocop", "~> 1.75"
  gem "rubocop-rails", "~> 2.32"
  gem "rubocop-performance", "~> 1.22"

  # RSpec関連
  gem "rspec-rails", "~> 7.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "shoulda-matchers", "~> 6.5"

  # debug関連
  gem "pry", "~> 0.15"
end

group :development do
  gem "web-console", "~> 4.2"  # Use console on exceptions pages
  gem "letter_opener_web", "~> 3.0"
end

group :test do
  gem "capybara", "~> 3.40"
  gem "selenium-webdriver", "~> 4.34"
end
