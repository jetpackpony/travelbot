require './lib/skyscanner_api/skyscanner_api'
require 'byebug'
require 'pry'
require 'dotenv'
Dotenv.load

=begin
req = SkyScannerAPI::LocationAutocompleteRequest.new
req.apiKey = ENV["SKYSCANNERAPI_KEY"]
req.market = "US"
req.currency = "USD"
req.locale = "en-EN"
req.query = "barcelona"

req.send_request.then do |res|
  puts res.body
end

=end

req = SkyScannerAPI::FlightsLivePricingRequest.new
req.apiKey = ENV["SKYSCANNERAPI_KEY"]
req.country = "US"
req.currency = "USD"
req.locale = "en-EN"
req.origin = "MOSC-sky"
req.destination = "BCN-sky"
req.departureDate = Date.parse("july 4th").strftime("%Y-%m-%d")
req.adultsNumber = 1
req.locationSchema = "Sky"

req.send_request.then do |res|
  r = JSON.parse(res.body)
  binding.pry
end
