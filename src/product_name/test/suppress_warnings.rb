#!/usr/bin/env ruby

require "warning"

# Suppress warnings from things outside of our control
Warning.ignore(/instance variable @\w+ not initialized/)
Warning.ignore(%r{/mnt/vendor/bundler/ruby/2.7.0/gems/bson-4.14.1/lib/bson})
Warning.ignore(%r{/usr/lib/ruby/2.7.0/cgi/cookie.rb})
Warning.ignore(%r{/usr/lib/ruby/2.7.0/cgi.rb})
Warning.ignore(%r{/mnt/vendor/bundler/ruby/2.7.0/gems/mongo-2.17.0/lib/mongo/})
