#!/usr/bin/env ruby

require "mongo"

require "database/transform"

# A simple wrapper around the MongoDB client
# that can be mocked out for unit tests

Mongo::Logger.logger.level = Logger::ERROR

module MyRetail
  class Database

    def initialize(host: nil, port: 27017, name: nil)
      @host = host
      @port = port
      @name = name

      @client = Mongo::Client.new("mongodb://#{host}:#{port}/#{name}")
    end

    def reset
      @client.database.drop
    end

    # Insert a document into a collection
    # collection: String
    # document: JSON Object
    # return: boolean
    def insert(collection, document)
      result = @client[collection].insert_one(document)
      result.successful? && result.written_count == 1
    end

    # Query a collection for a document
    # collection: String
    # filter: JSON Object, subset of document being queried for, or nil to get all documents
    # return: Array of JSON objects
    def query(collection, filter = nil)
      @client[collection].find(filter).map do |i|
        i.delete("_id")
        i.deep_symbolize_keys
      end
    end

    # Update an existing document
    # collection: String
    # filter: JSON Object, subset of document being queried for
    # document: JSON Object
    # return: boolean
    def update(collection, filter, document)
      result = @client[collection].update_one(filter, document, {upsert: true})
      result.successful? && result.written_count == 1
    end

    # Delete an existing document
    # collection: String
    # filter: JSON Object, subset of document being queried for
    # return: boolean
    def delete(collection, filter)
      result = @client[collection].delete_one(filter)
      result.successful? && result.written_count == 1
    end

  end
end
