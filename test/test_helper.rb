require 'test/unit'
require 'pp'
require 'mocha'

require 'turn'

ENV['RACK_ENV'] = 'test'
RACK_ROOT = File.expand_path('../..', __FILE__)

Thread.abort_on_exception = true
