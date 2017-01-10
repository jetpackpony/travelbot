require './lib/chat'
require './lib/scenario'
require 'pry'

scenario = TravelBot::Scenario.new
chat = TravelBot::Chat.new(scenario) do |msg|
  m = JSON.parse(msg)
  puts m["label"]
  if m["options"]
    m["options"].each { |o| puts o }
  end
end

parsed = JSON.parse File.read('dump.json')
res = chat.decorate_results parsed

binding.pry
