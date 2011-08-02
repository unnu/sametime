require "rubygems"
require "bundler/setup"
require "httparty"
require "active_support/ordered_hash"
require "active_support/json"

$:.unshift File.expand_path(File.dirname(__FILE__))

module Sametime
  extend self
  
  def escape(string)
    URI.escape(string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end
end

require 'sametime/base'
require 'sametime/room'
require 'sametime/chat'