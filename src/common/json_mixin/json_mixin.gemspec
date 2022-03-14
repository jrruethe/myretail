#!/usr/bin/env ruby
# frozen_string_literal: true
require "yaml"
metadata = YAML.load_file(File.join(__dir__, "Gemspec.yml"))

Gem::Specification.new do |spec|
  metadata.each do |k,v|
    spec.send("#{k.to_sym}=", v)
  end

  spec.require_paths = ["lib"]
  spec.files = Dir.glob("lib/**/*")

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "shoulda-context"
  spec.add_development_dependency "pry"
end
