#!/usr/bin/env ruby

module MyRetail
  class Combine

    def initialize(key, *clients)
      @key = key
      @clients = clients
    end

    def call(method, *args)

      # Call the clients
      result = @clients.map do |client|
        client.send(method, *args)
      end

      # Merge the results together
      case result.first
      when Hash
        return result.reduce(&:merge)
      when Array
        return result.flatten.group_by{|i| i[@key]}.values.map{|i| i.reduce(&:merge)}
      when nil
        return nil
      else
        return nil
      end

    end

  end
end
