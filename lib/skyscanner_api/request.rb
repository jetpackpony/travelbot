module SkyScannerAPI
  module Request
    API_HOST = "partners.api.skyscanner.net"
    AUTOCOMPLETE_PATH = "/apiservices/autosuggest"
    VERSION = "v1.0"

    attr_accessor :market, :currency, :locale, :apiKey

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

    def to_query(hash)
      hash.map do |k,v|
        [CGI::escape(k.to_s), "=", CGI::escape(v.to_s)]
      end
      .map(&:join)
      .join('&')
    end
  end
end
