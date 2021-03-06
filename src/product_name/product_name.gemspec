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
  spec.files = Dir.glob("{lib,bin}/**/*", File::FNM_DOTMATCH)

  spec.executables =
  [
    "app"
  ]

  spec.add_dependency "sinatra"
  spec.add_dependency "mongo"
  
  spec.add_dependency "json_mixin", "0.1.0"
  spec.add_dependency "database", "0.1.0"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "shoulda-context"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "warning"
  spec.add_development_dependency "pry"

end
