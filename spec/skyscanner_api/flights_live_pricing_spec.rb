require './lib/skyscanner_api/skyscanner_api'

RSpec.describe SkyScannerAPI::FlightsLivePricingRequest do
  describe "#get_results_from_session" do
    it "calls poll session set amount of times if not succeeded" do
      req = SkyScannerAPI::FlightsLivePricingRequest.new
      allow(req).to receive(:sleep)
      allow(req).to receive(:poll_session) { { complete?: false } }
      expect(req).to receive(:poll_session).exactly(10).times

      expect{
        req.send :get_results_from_session, "http://testme.com"
      }.to raise_error RuntimeError
    end

    it "calls poll_session once if it returns results" do
      req = SkyScannerAPI::FlightsLivePricingRequest.new
      allow(req).to receive(:sleep)
      allow(req).to receive(:poll_session) {
        { complete?: true, response: {} }
      }
      expect(req).to receive(:poll_session).once

      req.send :get_results_from_session, "http://testme.com"
    end
  end

  describe "#poll_session" do
    before(:each) do
      @res = instance_double(Net::HTTPResponse)
      allow(Net::HTTP).to receive(:start) { @res }
    end

    it "returns completed data if response code is 200" do
      req = SkyScannerAPI::FlightsLivePricingRequest.new
      req.apiKey = ""
      allow(req).to receive(:is_complete?) { true }
      allow(@res).to receive(:code) { "200" }
      success_object = { complete?: true, response: @res }
      expect(req.poll_session("http://testme.com")).to eq success_object
    end

    it "returns incomplete data if response code is not 200" do
      req = SkyScannerAPI::FlightsLivePricingRequest.new
      req.apiKey = ""
      allow(req).to receive(:is_complete?) { true }
      allow(@res).to receive(:code) { "300" }

      failure_object = { complete?: false, response: nil }
      expect(req.poll_session("http://testme.com")).to eq failure_object
    end
  end
end
