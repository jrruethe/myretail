#!/usr/bin/env ruby

require_relative "helper"

require "myretail/client"

class TestClient < Minitest::Test
  
  def setup
    if port_open?("host.docker.internal", 8081)
      @client = MyRetail::Client.new("host.docker.internal:8081", "/products")
      clear
    else
      skip "The dependent services are not running"
    end
  end

  # Clear the databases for each test
  def clear
    @client.list.each do |item|
      @client.delete(item[:id])
    end
  end

  context "client" do

    should "list" do
      result = @client.list
      assert_equal [], result

      data = {id: 1, name: "test"}
      result = @client.create(data.to_json)
      assert_equal data, result

      result = @client.list
      assert_equal [data], result
    end

    should "create" do
      data = {id: 1, name: "test"}
      result = @client.create(data.to_json)
      assert_equal data, result

      result = @client.read(1)
      assert_equal data, result
    end

    context "read" do

      should "200 on existing product" do
        data = {id: 1, name: "test"}
        result = @client.create(data.to_json)
        assert_equal data, result
  
        result = @client.read(1)
        assert_equal data, result
      end

      should "404 on missing product" do
        result = @client.read(1)
        assert_nil result
      end

    end

    should "update" do
      data = {id: 1, name: "test"}
      result = @client.create(data.to_json)
      assert_equal data, result

      result = @client.read(1)
      assert_equal data, result

      modification = {name: "modified"}
      result = @client.update(1, modification.to_json)
      data = {id: 1, name: "modified"}
      assert_equal data, result

      result = @client.read(1)
      assert_equal data, result
    end

    should "delete" do
      data = {id: 1, name: "test"}
      result = @client.create(data.to_json)
      assert_equal data, result

      result = @client.list
      assert_equal [data], result

      result = @client.delete(1)
      assert_equal data, result

      result = @client.list
      assert_equal [], result
    end

  end

end
