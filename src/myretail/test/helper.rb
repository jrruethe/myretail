#!/usr/bin/env ruby

require_relative "suppress_warnings"

require "minitest/autorun"
require "minitest/reporters"
require "shoulda/context"
require "rack/test"

# Specify a pretty-reporter
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require "socket"
def port_open?(host, port)
  begin
    TCPSocket.new(host, port.to_i)
    return true
  rescue
    return false
  end
end
