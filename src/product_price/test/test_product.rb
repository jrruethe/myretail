#!/usr/bin/env ruby

require_relative "helper"

require "product_price/product"

class TestProduct < Minitest::Test

  context "product" do

    should "have an id" do
      product = MyRetail::Product.new(id: 1, price: 1.5, currency: "USD")
      assert_equal 1, product.id
    end

    should "have a price" do
      product = MyRetail::Product.new(id: 1, price: 1.5, currency: "USD")
      assert_equal 1.5, product.price
    end

    should "have a currency" do
      product = MyRetail::Product.new(id: 1, price: 1.5, currency: "USD")
      assert_equal "USD", product.currency
    end

    should "create from hash" do
      hash = {id: 1, price: 1.5, currency: "USD"}
      product = MyRetail::Product.new(**hash)
      assert_equal 1, product.id
      assert_equal 1.5, product.price
      assert_equal "USD", product.currency
    end

    should "be a hash" do
      truth = {id: 1, price: 1.5, currency: "USD"}
      product = MyRetail::Product.new(**truth)
      hash = product.to_h
      assert_equal truth, hash
    end

    should "output json" do
      hash = {id: 1, price: 1.5, currency: "USD"}.sort_keys
      product = MyRetail::Product.new(**hash)
      json = product.to_json
      assert_equal hash.to_json, json
    end

    should "ignore extra data" do
      hash = {id: 1, price: 1.5, currency: "USD", extra: "ignore"}
      product = MyRetail::Product.new(**hash)
      truth = {id: 1, price: 1.5, currency: "USD"}.sort_by{|k,v| k}.to_h
      hash = product.to_h
      assert_equal truth, hash
      json = product.to_json
      assert_equal truth.to_json, json
    end

  end

end

class TestProductClass < Minitest::Test

  def setup
    MyRetail::Product.reset
  end

  context "product class" do

    should "list" do
      one = MyRetail::Product.new(id: 1, price: 1.5, currency: "USD")
      two = MyRetail::Product.new(id: 2, price: 3.14, currency: "USD")

      result = MyRetail::Product.create(id: 2, price: 3.14, currency: "USD")
      assert_equal two, result

      result = MyRetail::Product.create(id: 1, price: 1.5, currency: "USD")
      assert_equal one, result

      result = MyRetail::Product.list
      assert_equal 2, result.size
      
      assert_equal one, result[0]
      assert_equal two, result[1]
    end

    should "create" do
      result = MyRetail::Product.create(id: 1, price: 1.5, currency: "USD")
      truth = MyRetail::Product.new(id: 1, price: 1.5, currency: "USD")
      assert_equal truth, result

      result = MyRetail::Product.read(1)
      assert_equal truth, result
    end

    should "read" do
      result = MyRetail::Product.read(1)
      assert_nil result

      MyRetail::Product.create(id: 1, price: 1.5, currency: "USD")
      
      truth = MyRetail::Product.new(id: 1, price: 1.5, currency: "USD")
      result = MyRetail::Product.read(1)
      assert_equal truth, result
    end

    should "update" do
      MyRetail::Product.create(id: 1, price: 1.5, currency: "USD")
      MyRetail::Product.update(id: 1, price: 3.14, currency: "USD")

      truth = MyRetail::Product.new(id: 1, price: 3.14, currency: "USD")
      result = MyRetail::Product.read(1)
      assert_equal truth, result
    end

    should "delete" do
      MyRetail::Product.create(id: 1, price: 1.5, currency: "USD")
      MyRetail::Product.create(id: 2, price: 3.14, currency: "USD")

      result = MyRetail::Product.list
      assert_equal 2, result.size

      truth = MyRetail::Product.new(id: 1, price: 1.5, currency: "USD")
      result = MyRetail::Product.delete(1)
      assert_equal truth, result

      result = MyRetail::Product.list
      assert_equal 1, result.size

      truth = MyRetail::Product.new(id: 2, price: 3.14, currency: "USD")
      result = MyRetail::Product.read(2)
      assert_equal truth, result
    end

    should "reset" do
      MyRetail::Product.create(id: 1, price: 1.5, currency: "USD")
      
      result = MyRetail::Product.list
      assert_equal 1, result.size

      MyRetail::Product.reset

      result = MyRetail::Product.list
      assert_equal 0, result.size
    end

  end

end
