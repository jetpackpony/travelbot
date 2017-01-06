module SkyScannerAPI
  class LocationAutocompleteRequest
    include Request

    attr_accessor :query

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
  end
end
