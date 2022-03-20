#!/usr/bin/env ruby

require "sinatra"
require "rest-client"
require "json"

require "myretail/client"
require "myretail/combine"

product_name = MyRetail::Client.new(ENV["PRODUCT_NAME"], "/products")
product_price = MyRetail::Client.new(ENV["PRODUCT_PRICE"], "/products")
$combine = MyRetail::Combine.new(:id, product_name, product_price)

before do
  content_type "application/json"
end

# Health Check
get "/health" do
  content_type "text/html"
  [200, "OK"]
end

# Return a list of products
get "/products" do
  $combine.call(:list).to_json
end

# Create a new product
post "/products" do
  data = JSON.parse(request.body.read, symbolize_names: true)
  $combine.call(:create, data.to_json).to_json
end

# Retrieve a specific product
get "/products/:id" do |id|
  result = $combine.call(:read, id)
  return 404 unless result
  return result.to_json
end

# Update an existing product
put "/products/:id" do |id|
  data = JSON.parse(request.body.read, symbolize_names: true)
  $combine.call(:update, id, data.to_json).to_json
end

# Delete a product
delete "/products/:id" do |id|
  $combine.call(:delete, id).to_json
end
