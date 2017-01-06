require "./lib/scenario"

include TravelBot
RSpec.describe TravelBot::Scenario do
  describe "#get_question_by_name" do
    it "returns the question by it's name" do
      scenario = Scenario.new([
        { name: "test" },
        { name: "test-1" },
        { name: "test-2" }
      ])
      expect(scenario.get_question_by_name("test-1")).to eq({ name: "test-1" })
    end
  end

  describe "#request" do
    before(:each) do
      @scenario = Scenario.new([
        { name: "from-location-select", value: "from" },
        { name: "to-location-select", value: "to" },
        { name: "departure-date", value: "date" }
      ])
    end

    it "returns false if the form is not completed" do
      allow(@scenario).to receive(:complete?) { false }
      expect(@scenario.request).to be false
    end

    it "returns array of values if the form is completed" do
      allow(@scenario).to receive(:complete?) { true }
      expect(@scenario.request).to eq ["from", "to", "date"]
    end
  end
end
