#!/usr/bin/env ruby

require "json"

# If your class includes this module,
# it will automatically have the ability to output json
# as well as pretty print to strings

module JsonMixin

  # Extend a class with this module to get a dynamic sorter
  module Sorter
    def sort_on(*methods)

      # Automatically define a comparator
      define_method(:<=>) do |other|

        # Can only compare items if they are the same class
        return nil unless self.class == other.class

        # Get each object as JSON
        left  = self.as_json
        right = other.as_json

        # Pull out the values of the specified methods and compare them
        methods.map{|i| left[i]} <=> methods.map{|i| right[i]}
      end
    end
  end

  def self.included(obj)
    # JSON objects should be comparable and sortable
    obj.include Comparable
    obj.extend Sorter
  end

  def as_json(options = {})
    # Automatically adapt all public methods that take no parameters (getters)
    # Transform it into a key:value map
    public_methods(false)
    .map{|i| public_method(i)}
    .select{|i| i.parameters.empty?}
    .reject{|i| i.name =~ /[!?]$/}
    .reject{|i| i.name.to_s.start_with?("to_")}
    .sort_by{|i| i.to_s}
    .map{|i| [i.name, i.call]}
    .to_h
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  def to_h
    as_json
  end

  def to_s
    # Generate prettier JSON
    JSON.pretty_generate(as_json, {:space_before => " "}).gsub(/^(.*)(\"[^\"]+\") : ([\{\[])/, "\\1\\2 :\n\\1\\3")
  end

  def hash
    to_h.hash
  end

  def eql?(other)
    self == other
  end

end
