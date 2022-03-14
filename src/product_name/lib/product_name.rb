#!/usr/bin/env ruby

require "json_mixin"

class ProductName
  include JsonMixin

  def initialize(id, name)
    @id = id
    @name = name
  end

  attr_reader   :id
  attr_accessor :name

end