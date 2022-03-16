#!/usr/bin/env ruby

require "minitest/autorun"
require "minitest/reporters"
require "shoulda/context"
require "rack/test"

# Specify a pretty-reporter
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require "product_name"

class TestProductName < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context "product_name" do

    should "hello world" do

      response = get("/")
      assert_equal response.body, '{"id":0,"name":"Test"}'

    end

  end

end
