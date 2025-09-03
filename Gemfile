source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.3"

# Rails 7.0.8.7 (оставляем как у тебя; если решишь перейти на 7.1.x — скажу, что поменять)
gem "rails", "~> 7.0.8", ">= 7.0.8.7"

# DB / сервер / производительность
gem "pg", "~> 1.5"           # постгрес (чуть свежее твоего 1.1)
gem "puma", "~> 5.6"         # совместим с Ruby 3.2
gem "bootsnap", require: false
gem 'dotenv-rails'

# Front (Hotwire + Tailwind + Importmap)
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "rails-i18n", "~> 7.0"
gem "bcrypt", "~> 3.1"

# Auth
gem "devise"

# Админка
gem "trestle"
gem "trestle-auth"
gem "trestle-search"

# Background jobs
gem "sidekiq"
gem "redis"

# API/OpenAI
gem "openai"

# JSON helpers (можно убрать, если не используешь)
gem "jbuilder"

# zoneinfo для Windows (не мешает на Linux)
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Assets (sprockets по умолчанию в 7.0 можно держать)
gem "sprockets-rails"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "web-console"
  gem "letter_opener"
  gem "letter_opener_web"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
gem 'capistrano', '~> 3.18'; gem 'capistrano-rails'; gem 'capistrano3-puma'; gem 'capistrano-bundler'

gem "capistrano-passenger", "~> 0.2.1"
