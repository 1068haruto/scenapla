source "https://rubygems.org"

ruby "3.2.3"

gem "rails", "~> 7.2.1", ">= 7.2.1.1"
gem "sprockets-rails", "~> 3.5"
gem "pg", "~> 1.6"
gem "puma", ">= 7.1"
gem "jsbundling-rails", "~> 1.3"
gem "turbo-rails", "~> 2.0"
gem "stimulus-rails", "~> 1.3"
gem "cssbundling-rails", "~> 1.4"
gem "jbuilder", "~> 2.14"

gem "tzinfo-data", "~> 1.2023", platforms: %i[ windows jruby ]
gem "bootsnap", "~> 1.18", require: false

# ユーザー
gem "devise", "~> 4.9"
# auth
gem "omniauth", "~> 2.1"
gem "omniauth-google-oauth2", "~> 1.0"
gem "omniauth-rails_csrf_protection"
# グラフ表示
gem "chartkick", "~> 5.1"
gem "groupdate", "~> 6.5"
# ニュース
gem "http", "~> 5.3"
# AIアドバイス
gem "ruby-openai", "~> 8.3"

group :development, :test do
  gem "debug", "~> 1.11", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", "~> 7.1", require: false
  gem "rubocop-rails-omakase", "~> 1.0", require: false

  # rubocop
  gem "rubocop", "~> 1.75"
  gem "rubocop-rails", "~> 2.32"
  gem "rubocop-performance", "~> 1.22"
  # RSpec
  gem "rspec-rails", "~> 7.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "shoulda-matchers", "~> 6.5"
end

group :development do
  gem "web-console", "~> 4.2"
  gem "letter_opener_web", "~> 3.0"
end

group :test do
  gem "capybara", "~> 3.40"
  gem "selenium-webdriver", "~> 4.34"
end
