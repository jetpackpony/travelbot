require './lib/chat'
require './lib/scenario'
require 'byebug'

scenario = TravelBot::Scenario.new
chat = TravelBot::Chat.new(scenario) do |msg|
  puts msg
end
chat.start

loop do
  chat.push_message gets.chomp
end
