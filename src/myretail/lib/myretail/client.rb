#!/usr/bin/env ruby

require "json"
require "rest-client"

module MyRetail
  class Client

    def initialize(endpoint, basepath)
      @scheme = "http://"
      @endpoint = endpoint
      @basepath = basepath
      @headers = {content_type: :json}
    end

    def list
      process RestClient.get(@scheme + @endpoint + @basepath, @headers)
    end

    def read(id)
      begin
        process RestClient.get(@scheme + @endpoint + [@basepath, id].join("/"), @headers)
      rescue RestClient::NotFound
        return nil
      end
    end

    def create(data)
      process RestClient.post(@scheme + @endpoint + @basepath, data, @headers)
    end

    def update(id, data)
      process RestClient.put(@scheme + @endpoint + [@basepath, id].join("/"), data, @headers)
    end

    def delete(id)
      process RestClient.delete(@scheme + @endpoint + [@basepath, id].join("/"), @headers)
    end

    private

    def process(result)
      JSON.parse(result.body, symbolize_names: true)
    end

  end
end
