#!/usr/bin/env ruby

require_relative "suppress_warnings"

require "minitest/autorun"
require "minitest/reporters"
require "shoulda/context"
require "rack/test"

# Specify a pretty-reporter
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
