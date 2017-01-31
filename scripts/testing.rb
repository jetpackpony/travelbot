require './lib/chat'
require './lib/scenario'
require 'byebug'
require 'logger'
require 'pry'

logger = Logger.new(STDOUT)
scenario = TravelBot::Scenario.new
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
