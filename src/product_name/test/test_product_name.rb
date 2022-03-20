#!/usr/bin/env ruby

require_relative "helper"

require "product_name"

class TestProductName < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    MyRetail::Product.reset
  end 

  context "product_name" do

    should "pass a health check" do
      get "/health"
      assert_equal true, last_response.ok?
      assert_equal last_response.body, "OK"
    end

    should "list products" do
      get "/products"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal [], response

      data = {id: 1, name: "test"}
      post "/products", data.to_json, content_type: "application/json"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response

      get "/products"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal [data], response
    end

    should "create products" do
      data = {id: 1, name: "test"}
      post "/products", data.to_json, content_type: "application/json"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response

      get "/products/1"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response
    end

    context "read" do

      should "return existing products" do
        data = {id: 1, name: "test"}
        post "/products", data.to_json, content_type: "application/json"
        response = JSON.parse(last_response.body, symbolize_names: true)
        assert_equal data, response

        get "/products/1"
        response = JSON.parse(last_response.body, symbolize_names: true)
        assert_equal data, response
      end

      should "404 on missing products" do
        get "/products/1"
        assert_equal true, last_response.not_found?
      end

    end

    should "update products" do
      data = {id: 1, name: "test"}
      post "/products", data.to_json, content_type: "application/json"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response

      get "/products/1"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response

      modification = {name: "modified"}
      put "/products/1", modification.to_json, content_type: "application/json"
      response = JSON.parse(last_response.body, symbolize_names: true)
      data = {id: 1, name: "modified"}
      assert_equal data, response

      get "/products/1"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response
    end

    should "delete products" do
      data = {id: 1, name: "test"}
      post "/products", data.to_json, content_type: "application/json"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response

      get "/products/1"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response

      delete "/products/1"
      response = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal data, response

      get "/products/1"
      assert_equal true, last_response.not_found?
    end

  end

end
