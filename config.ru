require './app'
require './lib/middleware'

use TravelBot::WebSocketCatcher

run TravelBot::App
