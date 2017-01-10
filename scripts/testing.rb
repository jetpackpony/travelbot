require './lib/chat'
require './lib/scenario'
require 'byebug'

scenario = TravelBot::Scenario.new
chat = TravelBot::Chat.new(scenario) do |msg|
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
