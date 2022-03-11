#!/usr/bin/env ruby

require_relative "lib/json_mixin"

class HelloWorld
  include JsonMixin

  def initialize(name)
    @name = name
  end

  attr_reader :name
end

if $0 == __FILE__
  hello_world = HelloWorld.new("Joe")
  puts hello_world
end
