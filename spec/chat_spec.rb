require './lib/chat'
include TravelBot

RSpec.describe TravelBot::Chat do
  describe "#start" do
    it "calls the block with the first question from scenario" do
      scenario = double()
      allow(scenario).to receive(:current) { { question: "first question" } }
      chat = Chat.new(scenario) do |msg|
        expect(msg).to eq JSON.generate({ question: "first question" })
      end

      chat.start
    end
  end
  describe "#respond" do
    it "calls the block passed on object creation with message" do
      scenario = double()
      chat = Chat.new(scenario) do |msg|
        expect(msg).to eq "test message"
      end
      # This is a private method, so
      chat.send :respond, "test message"
    end
  end
end
