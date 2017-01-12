require "json"
require "dotenv"
Dotenv.load
require "./lib/skyscanner_api/skyscanner_api"

module TravelBot
  class Chat
    WAIT_MESSAGE = { type: :none, label: "Hold on I'll fetch you flight info" }
    NUMBER_OF_OPTIONS_TO_DISPLAY = 5

    def initialize(scenario, &send_action)
      @send_action = send_action
      @scenario = scenario
    end

    def start
      respond JSON.generate @scenario.current
    end

    def push_message(msg)
      @scenario.set_value = parse_value(@scenario, msg)
      if @scenario.complete?
        respond JSON.generate(WAIT_MESSAGE)
        flights = get_flights(*@scenario.request)
        decorated = decorate_results(flights)
        respond JSON.generate({ type: :none, label: decorated })
      else
        respond JSON.generate(@scenario.current)
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
      request.locationSchema = "Sky"

      promise = request.send_request
      value =
        begin
          promise.sync
        rescue
          raise "Couldn't query flights: #{[from, to, date].join(", ")}. #{promise.reason}"
        end

      JSON.parse(value.body)
    end

    def decorate_results(flights)
      query = flights["Query"]
      from = flights["Places"].find do |p|
        p["Id"] == query["OriginPlace"].to_i
      end
      to = flights["Places"].find do |p|
        p["Id"] == query["DestinationPlace"].to_i
      end
      date = query["OutboundDate"]

      itineraries = flights["Itineraries"]
        .slice(0, NUMBER_OF_OPTIONS_TO_DISPLAY)
        .map do |iti|
          res = {
            price: iti["PricingOptions"][0]["Price"],
            deeplink: iti["PricingOptions"][0]["DeeplinkUrl"],
          }

          leg = flights["Legs"].find { |leg| leg["Id"] == iti["OutboundLegId"] }
          res[:departure] = leg["Departure"]
          res[:arrival] = leg["Arrival"]
          res[:duration] = leg["Duration"]

          res[:stops] = leg["Stops"].map do |stop|
            flights["Places"].find { |p| p["Id"] == stop }
          end
          res[:carriers] = leg["OperatingCarriers"].map do |carrier|
            flights["Carriers"].find { |c| c["Id"] == carrier }
          end
          res
        end

      { from: from, to: to, date: date, itineraries: itineraries }
    end
  end
end
