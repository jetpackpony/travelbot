require "promise"

module SkyScannerAPI
  class LocationAutocompleteRequest
    API_HOST = "partners.api.skyscanner.net"
    AUTOCOMPLETE_PATH = "/apiservices/autosuggest"
    VERSION = "v1.0"

    attr_accessor :market, :currency, :locale, :query, :apiKey

    def initialize(options = {})
      @uri = nil
    end

    def send_request
      Promise.new.tap do |promise|
        response = perform_request
        if response.is_a?(Net::HTTPSuccess)
          promise.fulfill(response)
        else
          promise.reject(response)
        end
      end
    end

    private
    def perform_request
      uri = build_uri
      req = Net::HTTP::Get.new(uri)
      req['Accept'] = "application/json"

      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    end

    def build_uri
      URI::HTTP.build({
        host: API_HOST,
        path: [AUTOCOMPLETE_PATH, VERSION, @market, @currency, @locale].join('/'),
        query: to_query({
          query: @query,
          apiKey: @apiKey
        })
      })
    end

    def to_query(hash)
      hash.map do |k,v|
        [CGI::escape(k.to_s), "=", CGI::escape(v.to_s)]
      end
        .map(&:join)
        .join('&')
    end
  end
end
