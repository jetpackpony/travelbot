require './lib/skyscanner_api'
require 'byebug'
require 'dotenv'
Dotenv.load

req = SkyScannerAPI::LocationAutocompleteRequest.new
req.apiKey = ENV["SKYSCANNERAPI_KEY"]
req.market = "US"
req.currency = "USD"
req.locale = "en-EN"
req.query = "barcelona"

req.send_request.then do |res|
  puts res.body
end

