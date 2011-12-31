require "rubygems"
require "bundler/setup"
require "httparty"
require "httmultiparty"
require "active_support/ordered_hash"
require "active_support/json"

$:.unshift File.expand_path(File.dirname(__FILE__))

module Sametime
  extend self
  
  def escape(string)
    URI.escape(string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end
end

require 'sametime/map'
require 'sametime/base'
require 'sametime/document'
require 'sametime/url'
require 'sametime/library'
require 'sametime/chat'
require 'sametime/projector'
require 'sametime/room'