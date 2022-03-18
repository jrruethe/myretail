#!/usr/bin/env ruby

require "sinatra"

require "product_name/database"
require "product_name/product"

# Create a database and give it to Sinatra
begin
  database = MyRetail::Database.new(host: "product-name-database.localhost", name: "product_name")
  set :database, database
rescue Mongo::Error::SocketError
  set :database, nil
end

# Health Check
get "/health" do
  content_type "text/html"
  [200, "OK"]
end

# Return a list of products
get "/products" do
  content_type "application/json"
end

# Retrieve a specific product
get "/products/:id" do
  content_type "application/json"
end

# Update an existing product
put "/products/:id" do
  content_type "application/json"
end

# Create a new product
post "/products" do
  content_type "application/json"
end

# Delete a product
delete "/products/:id" do
  content_type "application/json"
end
