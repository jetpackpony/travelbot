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
      @scenario = instance_double("TravelBot::Scenario")
      @current_step = double
      allow(@scenario).to receive(:request) { [1, 2, 3] }
      allow(@scenario).to receive(:set_value=)
      allow(@scenario).to receive(:complete?) { false }
      allow(@scenario).to receive(:current) { @current_step }
      @chat = Chat.new(@scenario) {}
      allow(@chat).to receive(:parse_value) { 'testme' }
      allow(@chat).to receive(:respond) { 'testme' }
      allow(@chat).to receive(:get_flights) { "flight_list" }
    end

    it "sets the value of the current step of the scenario" do
      expect(@scenario).to receive(:set_value=).with("testme")
      @chat.push_message("test")
    end

    it "responds with the current step if the scenario is incomplete" do
      allow(@scenario).to receive(:complete?) { false }
      expect(@chat).to receive(:respond).with(JSON.generate(@current_step))
      @chat.push_message("test")
    end

    it "responds with the wait message if the scenario is complete" do
      allow(@scenario).to receive(:complete?) { true }
      expect(@chat).to receive(:respond).with(JSON.generate(TravelBot::Chat::WAIT_MESSAGE))
      @chat.push_message("test")
    end

    it "responds with the flights list when flights are collected" do
      allow(@scenario).to receive(:complete?) { true }
      @chat.push_message("test")
      expect(@chat).to have_received(:respond).twice
    end
  end
end
