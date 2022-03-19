#!/usr/bin/env ruby

require_relative "helper"

require "database"
require "database/mock"

# Verify that the mock is working as intended
class TestMockDatabase < Minitest::Test

  def setup
    @database = MockDatabase.new
  end

  context "insert" do
    should "insert a document into the database" do
      document = {hello: "world"}
      result = @database.insert(:test, document)
      assert_equal true, result
    end

    # should "not allow duplicate documents to be inserted" do
    #   document = {hello: "world"}
    #   result = @database.insert(:test, document)
    #   assert_equal true, result
    #   result = @database.insert(:test, document)
    #   assert_equal false, result
    # end
  end

  context "query" do

    should "return an empty list" do
      result = @database.query(:test)
      assert_equal [], result
    end

    should "list all documents" do
      document = {hello: "world"}
      result = @database.insert(:test, document)
      assert_equal true, result
      result = @database.query(:test)
      assert_equal 1, result.size
      assert_equal document, result.first
    end

    should "list duplicate documents" do
      document = {hello: "world"}
      result = @database.insert(:test, document)
      assert_equal true, result
      result = @database.insert(:test, document)
      assert_equal true, result
      result = @database.query(:test)
      assert_equal 2, result.size
      assert_equal document, result[0]
      assert_equal document, result[1]
    end

    should "subset filter" do
      document = {first_name: "john", last_name: "smith"}
      result = @database.insert(:test, document)
      assert_equal true, result

      document = {first_name: "john", last_name: "anderson"}
      result = @database.insert(:test, document)
      assert_equal true, result

      document = {first_name: "bob", last_name: "smith"}
      result = @database.insert(:test, document)
      assert_equal true, result

      result = @database.query(:test)
      assert_equal 3, result.size
      
      result = @database.query(:test, {first_name: "john"})
      assert_equal 2, result.size

      assert_equal true, result.include?({first_name: "john", last_name: "smith"})
      assert_equal true, result.include?({first_name: "john", last_name: "anderson"})

      result = @database.query(:test, {last_name: "smith"})
      assert_equal 2, result.size

      assert_equal true, result.include?({first_name: "john", last_name: "smith"})
      assert_equal true, result.include?({first_name: "bob", last_name: "smith"})
    end

    should "unique filter" do
      document = {first_name: "john", last_name: "smith"}
      result = @database.insert(:test, document)
      assert_equal true, result

      document = {first_name: "john", last_name: "anderson"}
      result = @database.insert(:test, document)
      assert_equal true, result

      document = {first_name: "bob", last_name: "smith"}
      result = @database.insert(:test, document)
      assert_equal true, result

      result = @database.query(:test)
      assert_equal 3, result.size
      
      result = @database.query(:test, {first_name: "john", last_name: "smith"})
      assert_equal 1, result.size

      assert_equal true, result.include?({first_name: "john", last_name: "smith"})
    end

  end

  context "update" do

    should "insert a document into the database" do
      document = {hello: "world"}
      filter = {hello: "world"}
      result = @database.update(:test, filter, document)
      assert_equal true, result
    end

    should "update a document in the database" do
      document = {hello: "world", goodnight: "moon"}
      result = @database.insert(:test, document)
      assert_equal true, result

      document = {hello: "world", goodnight: "earth"}
      filter = {hello: "world"}
      result = @database.update(:test, filter, document)
      assert_equal true, result

      result = @database.query(:test, {hello: "world"})
      assert_equal 1, result.size
      assert_equal "earth", result[0][:goodnight]
    end

  end

  context "delete" do

    should "delete a document from the database" do
      document = {first_name: "john", last_name: "smith"}
      result = @database.insert(:test, document)
      assert_equal true, result

      document = {first_name: "john", last_name: "anderson"}
      result = @database.insert(:test, document)
      assert_equal true, result

      result = @database.query(:test)
      assert_equal 2, result.size

      filter = {last_name: "smith"}
      result = @database.delete(:test, filter)
      assert_equal true, result

      result = @database.query(:test)
      assert_equal 1, result.size
      truth = {first_name: "john", last_name: "anderson"}
      assert_equal truth, result[0]
    end

  end

end

require "socket"
def port_open?(host, port)
  begin
    TCPSocket.new(host, port.to_i)
    return true
  rescue
    return false
  end
end

# Run the exact same tests against the real database
class TestRealDatabase < TestMockDatabase
  
  def setup
    if port_open?("host.docker.internal", 27017)
      @database = MyRetail::Database.new(host: "host.docker.internal", name: "product_name")
      @database.reset
    else
      skip "The database is not running"
    end
  end

end

# If the behavior of the mock matches the behavior of the real database,
# then the mock can be used in unit tests for the rest of the application
