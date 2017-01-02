require './lib/chat'
include TravelBot

RSpec.describe TravelBot::Chat do
  describe "#respond" do
    it "calls the block passed on object creation with message" do
      chat = Chat.new do |msg|
        expect(msg).to eq "test message"
      end
      # This is a private method, so
      chat.send :respond, "test message"
    end
  end
end
