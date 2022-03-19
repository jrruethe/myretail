#!/usr/bin/env ruby

require_relative "helper"

require "product_name/product"

class TestProduct < Minitest::Test

  context "product" do

    should "have an id" do
      product = MyRetail::Product.new(id: 1, name: "test")
      assert_equal 1, product.id
    end

    should "have a name" do
      product = MyRetail::Product.new(id: 1, name: "test")
      assert_equal "test", product.name
    end

    should "create from hash" do
      hash = {id: 1, name: "test"}
      product = MyRetail::Product.new(**hash)
      assert_equal 1, product.id
      assert_equal "test", product.name
    end

    should "be a hash" do
      truth = {id: 1, name: "test"}
      product = MyRetail::Product.new(**truth)
      hash = product.to_h
      assert_equal truth, hash
    end

    should "output json" do
      hash = {id: 1, name: "test"}
      product = MyRetail::Product.new(**hash)
      json = product.to_json
      assert_equal hash.to_json, json
    end

    should "ignore extra data" do
      hash = {id: 1, name: "test", extra: "ignore"}
      product = MyRetail::Product.new(**hash)
      truth = {id: 1, name: "test"}
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
      one = MyRetail::Product.new(id: 1, name: "test")
      two = MyRetail::Product.new(id: 2, name: "another")

      result = MyRetail::Product.create(id: 2, name: "another")
      assert_equal two, result

      result = MyRetail::Product.create(id: 1, name: "test")
      assert_equal one, result

      result = MyRetail::Product.list
      assert_equal 2, result.size
      
      assert_equal one, result[0]
      assert_equal two, result[1]
    end

    should "create" do
      result = MyRetail::Product.create(id: 1, name: "test")
      truth = MyRetail::Product.new(id: 1, name: "test")
      assert_equal truth, result

      result = MyRetail::Product.read(1)
      assert_equal truth, result
    end

    should "read" do
      result = MyRetail::Product.read(1)
      assert_nil result

      MyRetail::Product.create(id: 1, name: "test")
      
      truth = MyRetail::Product.new(id: 1, name: "test")
      result = MyRetail::Product.read(1)
      assert_equal truth, result
    end

    should "update" do
      MyRetail::Product.create(id: 1, name: "test")
      MyRetail::Product.update(id: 1, name: "modified")

      truth = MyRetail::Product.new(id: 1, name: "modified")
      result = MyRetail::Product.read(1)
      assert_equal truth, result
    end

    should "delete" do
      MyRetail::Product.create(id: 1, name: "test")
      MyRetail::Product.create(id: 2, name: "another")

      result = MyRetail::Product.list
      assert_equal 2, result.size

      truth = MyRetail::Product.new(id: 1, name: "test")
      result = MyRetail::Product.delete(1)
      assert_equal truth, result

      result = MyRetail::Product.list
      assert_equal 1, result.size

      truth = MyRetail::Product.new(id: 2, name: "another")
      result = MyRetail::Product.read(2)
      assert_equal truth, result
    end

    should "reset" do
      MyRetail::Product.create(id: 1, name: "test")
      
      result = MyRetail::Product.list
      assert_equal 1, result.size

      MyRetail::Product.reset

      result = MyRetail::Product.list
      assert_equal 0, result.size
    end

  end

end
