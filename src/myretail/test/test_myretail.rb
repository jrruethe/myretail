#!/usr/bin/env ruby

require_relative "helper"

require "myretail"

class TestMyRetail < Minitest::Test
  
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    if port_open?("host.docker.internal", 8081) && port_open?("host.docker.internal", 8082)
      product_name = MyRetail::Client.new("host.docker.internal:8081", "/products")
      product_price = MyRetail::Client.new("host.docker.internal:8082", "/products")
      $combine = MyRetail::Combine.new(:id, product_name, product_price)
      clear
    else
      skip "The dependent services are not running"
    end
  end

  # Clear the databases for each test
  def clear
    get "/products"
    response = JSON.parse(last_response.body, symbolize_names: true)
    response.each do |item|
      delete "/products/#{item[:id]}"
    end
  end

  context "myretail" do

    should "list" do
      get "/products"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal [], response

      data = {id: 1, name: "test", price: 1.5, currency: "USD"}
      post "/products", data.to_json, content_type: "application/json"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response

      get "/products"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal [data], response
    end

    should "create" do
      data = {id: 1, name: "test", price: 1.5, currency: "USD"}
      post "/products", data.to_json, content_type: "application/json"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response

      get "/products/1"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response
    end

    context "read" do

      should "200 on existing product" do
        data = {id: 1, name: "test", price: 1.5, currency: "USD"}
        post "/products", data.to_json, content_type: "application/json"
        response = JSON.parse(last_response.body, symbolize_names: true)
        assert_equal data, response
  
        get "/products/1"
        response = JSON.parse(last_response.body, symbolize_names: true)
        assert_equal data, response
      end

      should "404 on missing product" do
        get "/products/1"
        assert_equal true, last_response.not_found?
      end

    end

    should "update" do
      data = {id: 1, name: "test", price: 1.5, currency: "USD"}
      post "/products", data.to_json, content_type: "application/json"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response

      modified = {price: 3.14}
      put "/products/1", modified.to_json, content_type: "application/json"
      response = JSON.parse(last_response.body, symbolize_names: true)
      data = {id: 1, name: "test", price: 3.14, currency: "USD"}
      assert_equal data, response

      get "/products/1"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response
    end

    should "delete" do
      data = {id: 1, name: "test", price: 1.5, currency: "USD"}
      post "/products", data.to_json, content_type: "application/json"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response

      get "/products"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal [data], response

      delete "/products/1"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response

      get "/products"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal [], response
    end

  end

end
