# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
# AdminLTE_sample

```
$ bundle init
```

Gemfile

```
# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'rails'
```

```
$ bundle install --path vendor/bundle
$ bundle exec rails new . --skip-action-mailer --skip-active-storage --skip-action-cable 
$ bundle install --path vendor/bundle  
$ yarn install --check-files
$ bin/rails g devise:install 
$ bundle exec ridgepole --config ./config/database.yml --file ./db/Schemafile --apply
$ bin/rails db:seed_fu      
```

### export 
```
bundle exec ridgepole -c config/database.yml -E development --export -o db/Schemafile
```
