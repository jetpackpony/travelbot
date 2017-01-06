require "json"
require_relative "./skyscanner_api"
require "pry"
require "dotenv"
Dotenv.load

module TravelBot
  class Chat
    WAIT_MESSAGE = { type: :none, label: "Hold on I'll fetch you flight info" }
    def initialize(scenario, &send_action)
      @send_action = send_action
      @scenario = scenario
    end

    def start
      respond JSON.generate @scenario.current
    end

    def push_message(msg)
      @scenario.set_value = parse_value(@scenario, msg)
      respond JSON.generate(
        @scenario.complete? ? WAIT_MESSAGE : @scenario.current
      )
      if @scenario.complete?
        flights = get_flights(*@scenario.data)
      end
    end

    private
    def respond(msg)
      @send_action.call msg
    end

    def parse_value(scenario, msg)
      case scenario.current[:type]
      when :text
        search_location(msg)
      when :select
        parse_option(scenario, msg)
      when :date
        parse_date(msg)
      end
    end

    def search_location(msg)
      request = SkyScannerAPI::LocationAutocompleteRequest.new
      request.market = "US"
      request.currency = "USD"
      request.locale = "en-EN"
      request.apiKey = ENV["SKYSCANNERAPI_KEY"]
      request.query = msg

      promise = request.send_request
      value =
        begin
          promise.sync
        rescue
          raise "Couldn't query the country: #{promise.reason}"
        end

      JSON.parse(value.body)["Places"].map do |p|
        { id: p["PlaceId"], name: "#{p["PlaceName"]}, #{p["CountryName"]}" }
      end
    end

    def parse_option(scenario, msg)
      scenario.current[:options].find { |item| item[:id] == msg }
    end

    def parse_date(msg)
      begin
        Date.parse(msg)
      rescue
        "Couldn't parse the date"
      end
    end

    def get_flights(from, to, date)
      request = SkyScannerAPI::FlightsLivePricingRequest.new
      request.country = "US"
      request.currency = "USD"
      request.locale = "en-EN"
      request.apiKey = ENV["SKYSCANNERAPI_KEY"]
      request.origin = from[:id]
      request.destination = to[:id]
      request.departureDate = date.strftime("%Y-%m-%d")
      request.adultsNumber = 1
      request.locationschema = "Sky"

      promise = request.send_request
      value =
        begin
          promise.sync
        rescue
          raise "Couldn't query flights: #{[from, to, date].join(", ")}. #{promise.reason}"
        end

      JSON.parse(value.body)
    end
  end
end
