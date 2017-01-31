require './lib/chat'
require './lib/scenario'
require 'byebug'
require 'logger'
require 'pry'

logger = Logger.new(STDOUT)

scenario = TravelBot::Scenario.new
scenario.set_value = [ { id: 'BCN-sky', name: 'Barcelona' } ]
scenario.set_value = { id: 'BCN-sky', name: 'Barcelona' }
scenario.set_value = Date.parse 'april 1st'
scenario.set_value = [ { id: 'MOSC-sky', name: 'Moscow' } ]

chat = TravelBot::Chat.new(scenario, logger) do |msg|
  m = JSON.parse(msg)
  puts m["label"]
  if m["options"]
    m["options"].each { |o| puts o }
  end
end
chat.start

loop do
  chat.push_message gets.chomp
end
