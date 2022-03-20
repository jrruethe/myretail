#!/usr/bin/env ruby

require_relative "helper"

require "myretail/combine"

class MockClient
  [
    :list,
    :create,
    :read,
    :update,
    :delete
  ].each do |method|
    result = (method.to_s + "_result").to_sym
    attr_accessor result
    define_method(method) do |*args|
      send(result)
    end
  end
end

class TestCombine < Minitest::Test

  should "combine read results" do

    product_name  = MockClient.new
    product_price = MockClient.new

    product_name.read_result = {id: 1, name: "test"}
    product_price.read_result = {id: 1, price: 1.5, currency: "USD"}

    combine = MyRetail::Combine.new(:id, product_name, product_price)

    result = combine.call(:read, 1)
    
    assert_equal 1,      result[:id]
    assert_equal "test", result[:name]
    assert_equal 1.5,    result[:price]
    assert_equal "USD",  result[:currency]

  end

  should "handle 404/nil" do

    product_name  = MockClient.new
    product_price = MockClient.new

    product_name.read_result = nil
    product_price.read_result = nil

    combine = MyRetail::Combine.new(:id, product_name, product_price)

    result = combine.call(:read, 1)
    
    assert_nil result
    
  end

  should "combine list results" do

    product_name  = MockClient.new
    product_price = MockClient.new

    product_name.list_result = [{id: 1, name: "test"}, {id: 2, name: "another"}]
    product_price.list_result = [{id: 1, price: 1.5, currency: "USD"}, {id: 2, price: 3.14, currency: "USD"}]

    combine = MyRetail::Combine.new(:id, product_name, product_price)

    result = combine.call(:list)
    
    assert_equal 2, result.size

    result = result.sort_by{|i| i[:id]}
    assert_equal 1,      result[0][:id]
    assert_equal "test", result[0][:name]
    assert_equal 1.5,    result[0][:price]
    assert_equal "USD",  result[0][:currency]

    assert_equal 2,      result[1][:id]
    assert_equal "another", result[1][:name]
    assert_equal 3.14,    result[1][:price]
    assert_equal "USD",  result[1][:currency]
  end

end
