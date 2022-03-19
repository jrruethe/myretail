#!/usr/bin/env ruby

require "sinatra"
require "json"

require "product_name/product"

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
  MyRetail::Product.list.to_json
end

# Create a new product
post "/products" do
  data = JSON.parse(request.body.read, symbolize_names: true)
  MyRetail::Product.create(**data).to_json
end

# Retrieve a specific product
get "/products/:id" do |id|
  id = id.to_i
  product = MyRetail::Product.read(id)
  return 404 unless product
  return product.to_json
end

# Update an existing product
put "/products/:id" do |id|
  id = id.to_i
  data = JSON.parse(request.body.read, symbolize_names: true).merge({id: id})
  MyRetail::Product.update(**data).to_json
end

# Delete a product
delete "/products/:id" do |id|
  id = id.to_i
  MyRetail::Product.delete(id).to_json
end
