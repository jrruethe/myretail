#!/usr/bin/env ruby

require "json_mixin"

class Product
  include JsonMixin

  def initialize(id, name)
    @id = id
    @name = name
  end

  attr_reader   :id
  attr_accessor :name

end
