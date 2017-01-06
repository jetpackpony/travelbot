module SkyScannerAPI
  class FlightsLivePricingRequest
    LIVE_PRICING_CREATE_SESSION_PATH = "/apiservices/pricing"
    MAX_POLL_TRIES = 10
    include Request

    attr_accessor :query, :origin, :destination, :departureDate, :adultsNumber, :locationSchema

    def perform_request
      session = create_session
      if session.is_a?(Net::HTTPSuccess) && session['location']
        get_results_from_session(session['location'])
      else
        session
      end
    end

    def create_session
      uri = build_session_uri
      params = {
        apiKey: @apiKey,
        country: @country,
        currency: @currency,
        locale: @locale,
        originplace: @origin,
        destinationplace: @destination,
        outbounddate: @departureDate,
        adults: @adultsNumber,
        locationschema: @locationSchema
      }
      headers = {'Accept' => 'application/json'}

      req = Net::HTTP::Post.new(uri)
      req.set_form_data params
      headers.each do |key, val|
        req[key] = val
      end

      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    end

    def build_session_uri
      URI::HTTP.build({
        host: API_HOST,
        path: [LIVE_PRICING_CREATE_SESSION_PATH, VERSION].join('/'),
        query: to_query({
          query: @query,
          apiKey: @apiKey
        })
      })
    end

    def get_results_from_session(session_uri)
      try_id = 0
      while try_id < MAX_POLL_TRIES do
        sleep 10
        try_id += 1

        res = poll_session(session_uri)
        if res[:complete?]
          return res[:response]
        end
      end
      raise "Failed to load results for #{session_uri}"
    end

    def poll_session(session_uri)
      uri = URI("" + session_uri + "?apiKey=" + @apiKey)
      req = Net::HTTP::Get.new(uri)
      req['Accept'] = "application/json"

      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end

      if res.code == "200"
        { complete?: is_complete?(res), response: res }
      else
        { complete?: false, response: nil }
      end
    end

    def is_complete?(response)
      JSON.parse(response.body)["Status"] == "UpdatesComplete"
    end
  end
end
