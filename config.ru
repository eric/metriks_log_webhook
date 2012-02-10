require 'bundler'
Bundler.require :default

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

RACK_ENV  = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
RACK_ROOT = File.expand_path('..', __FILE__)

require 'metriks_log_webhook/app'

run MetriksLogWebhook::App.new
