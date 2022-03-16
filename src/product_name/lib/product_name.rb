#!/usr/bin/env ruby

require "sinatra"
require "mongo"

require "product_name/product"

get "/" do
  Product.new(0, "Test").to_json
end
