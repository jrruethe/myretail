#!/usr/bin/env ruby

require_relative "helper"

require "product_name"

class TestProductName < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context "product_name" do
    should "pass a health check" do
      response = get("/health")
      # assert_equal response.code 200
      assert_equal response.body, "OK"
    end
  end

end
