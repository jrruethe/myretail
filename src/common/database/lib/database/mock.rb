#!/usr/bin/env ruby

require "database"

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
    result = query(collection, filter)
    if result.empty?
      return insert(collection, document)
    else
      result.map{|i| i.merge!(document)}
      return result.size > 0
    end
  end

  def delete(collection, filter)
    before = @db[collection].size
    result = @db[collection].delete_if{|i| filter.map{|k,v| i[k] == v}.all?}
    return result.size < before
  end

end
