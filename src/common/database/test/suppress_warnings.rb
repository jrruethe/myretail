#!/usr/bin/env ruby

require "warning"

# Suppress warnings from things outside of our control
[
  %r{/mnt/vendor/bundler/ruby/.*/gems/mongo-.*/lib/mongo},
  %r{/mnt/vendor/bundler/ruby/.*/gems/bson-.*/lib/bson},
].each{|i| Warning.ignore(i)}
