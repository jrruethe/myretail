#!/usr/bin/env ruby

require "minitest/autorun"
require "minitest/reporters"
require "shoulda/context"

# Specify a pretty-reporter
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require "json_mixin"

class DummyClass
  include JsonMixin

  def getter
    3
  end

  def hash_
    {
      one: 1,
      two: 2,
    }
  end

  def array
    [
      1,
      2,
      3,
    ]
  end

  def question?
    true
  end

  def method(value)
    value
  end

  def setter=(value)
    value
  end

  def bang!
    4
  end

  def block(&block)
    block.call
  end

  def default(value=5)
    value
  end

  def optional(value: 6)
    value
  end

  def to_conversion
    7
  end

  def _ignore
    8
  end 

end

class ComparableClass
  include JsonMixin

  def initialize(a, b, c)
    @a = a
    @b = b
    @c = c
  end

  def first
    @a
  end

  def second
    @b
  end

  def third
    @c
  end

  sort_on :first, :third
end

class TestJsonMixin < Minitest::Test

  context "json_mixin" do

    setup do
      @dummy = DummyClass.new
    end

    should "be comparable" do
      a = ComparableClass.new(1, 9, 1)
      b = ComparableClass.new(1, 1, 2)
      c = ComparableClass.new(2, 0, 1)

      assert_equal true, a < b
      assert_equal true, b < c
      assert_equal true, a < c
    end

    should "be equal" do
      a = ComparableClass.new(1, 2, 3)
      b = ComparableClass.new(1, 2, 3)
      assert true, a == b
      assert true, a.eql?(b)
    end

    should "be uniq-able" do
      a = ComparableClass.new(1, 2, 3)
      b = ComparableClass.new(1, 2, 3)
      array = [a, b]
      array.uniq!
      assert_equal 1, array.size
    end

    should "only pull out getters" do
      assert_equal 3,       @dummy.as_json.size
      assert_equal :array,  @dummy.as_json.keys[0]
      assert_equal :getter, @dummy.as_json.keys[1]
      assert_equal :hash_,   @dummy.as_json.keys[2]
    end

    should "be convertable to json" do
      truth = '{"array":[1,2,3],"getter":3,"hash_":{"one":1,"two":2}}'
      assert_equal truth, @dummy.to_json
    end

    should "be pretty-printable" do
      # Heredoc
      truth = <<~END
      {
        "array" :
        [
          1,
          2,
          3
        ],
        "getter" : 3,
        "hash_" :
        {
          "one" : 1,
          "two" : 2
        }
      }
      END
      .chomp # Remove trailing newline

      assert_equal truth, @dummy.to_s
    end

  end

end
