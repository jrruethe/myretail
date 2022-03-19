#!/usr/bin/env ruby

require_relative "helper"

require "database/transform"

class TestTransform < Minitest::Test

  context "tranform" do

    should "symbolize keys" do

      test = {"one": {"two": "three"}}
      result = test.deep_symbolize_keys
      truth = {one: {two: "three"}}
      assert_equal truth, result

    end

  end

end
