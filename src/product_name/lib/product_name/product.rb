#!/usr/bin/env ruby

require "json_mixin"

require "database"
require "database/mock"

module MyRetail
  class Product
    include JsonMixin

    def initialize(id: nil, name: nil, **kwargs)
      @id = id
      @name = name
    end

    attr_reader   :id
    attr_accessor :name
    sort_on :id

    ###########################################################################

    # Connect to the database, or fall back to the mock database
    begin
      host = ENV["DBHOST"] || "host.docker.internal"
      name = ENV["DBNAME"] || "product_name"
      @@database = MyRetail::Database.new(host: host, name: name)
      STDERR.puts "USING REAL DATABASE: #{ENV["DBHOST"]}"
    rescue Mongo::Error::SocketError
      @@database = MyRetail::MockDatabase
      STDERR.puts "USING MOCK DATABASE"
    end

    # Specify the collection name
    COLLECTION = :product_name

    # CRUD functions for the product

    def self.reset
      @@database.reset
    end

    def self.list
      @@database.query(COLLECTION).map{|i| Product.new(**i)}.sort
    end

    def self.read(id)
      @@database.query(COLLECTION, {id: id}).map{|i| Product.new(**i)}.first
    end

    def self.create(id: nil, name: nil, **kwargs)
      product = Product.new(id: id, name: name)
      @@database.insert(COLLECTION, product.to_h)
      return product
    end

    def self.update(id: nil, name: nil, **kwargs)
      product = Product.new(id: id, name: name)
      @@database.update(COLLECTION, {id: id}, product.to_h)
      return product
    end

    def self.delete(id)
      product = read(id)
      @@database.delete(COLLECTION, {id: id})
      return product
    end

  end
end
