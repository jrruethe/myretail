#!/usr/bin/env ruby
# frozen_string_literal: true
require "yaml"
metadata = YAML.load_file(File.join(__dir__, "Gemspec.yml"))

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  metadata.each do |k,v|
    spec.send("#{k.to_sym}=", v)
  end
  spec.files = Dir.glob("{lib}/**/*", File::FNM_DOTMATCH)

  spec.add_dependency "mongo"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "shoulda-context"
  spec.add_development_dependency "warning"
  spec.add_development_dependency "pry"
  
end
