#!/usr/bin/env ruby

require_relative "helper"

require "product_name/database"

# A mock to define the behavior of the database
class MockDatabase < MyRetail::Database

  def initialize
    reset
  end

  def reset
    @db = Hash.new([])
  end

  def insert(collection, document)
    @db[collection] << document
    return true
  end

  def query(collection, filter = {})
    @db[collection].select{|i| filter.map{|k,v| i[k] == v}.all?}
  end

  def update(collection, filter, document)
    result = query(collection, filter).map{|i| i.merge(document)}
    return result.size > 0
  end

  def delete(collection, filter)
    before = @db[collection].size
    result = @db[collection].delete_if{|i| filter.map{|k,v| i[k] == v}.all?}
    return result.size < before
  end

  def upsert(collection, filter, document)
    if query(collection, filter).empty?
      insert(collection, document)
    else
      update(collection, filter, document)
    end
  end

end

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

    should "" do

    end

  end

  context "delete" do

    should "" do

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
