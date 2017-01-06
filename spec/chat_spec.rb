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

  describe "#push_message" do
    before(:each) do
      @scenario = double
      @current_step = double
      allow(@scenario).to receive(:data) { [1, 2, 3] }
      allow(@scenario).to receive(:set_value=)
      allow(@scenario).to receive(:complete?) { false }
      allow(@scenario).to receive(:current) { @current_step }
      @chat = Chat.new(@scenario) {}
      allow(@chat).to receive(:parse_value) { 'testme' }
      allow(@chat).to receive(:respond) { 'testme' }
    end

    it "sets the value of the current step of the scenario" do
      allow(@scenario).to receive(:set_value=) do |value|
        expect(value).to eq 'testme'
      end

      @chat.push_message("test")
    end

    it "responds with the current step if the scenario is incomplete" do
      allow(@scenario).to receive(:complete?) { false }
      allow(@chat).to receive(:respond) do |msg|
        expect(msg).to eq(JSON.generate(@current_step))
      end

      @chat.push_message("test")
    end

    it "responds with the wait message if the scenario is complete" do
      allow(@scenario).to receive(:complete?) { true }
      allow(@chat).to receive(:get_flights)
      allow(@chat).to receive(:respond) do |msg|
        expect(msg).to eq(JSON.generate(TravelBot::Chat::WAIT_MESSAGE))
      end

      @chat.push_message("test")
    end
  end
end
