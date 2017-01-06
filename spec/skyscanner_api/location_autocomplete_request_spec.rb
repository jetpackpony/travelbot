require './lib/skyscanner_api/skyscanner_api'

RSpec.describe SkyScannerAPI::LocationAutocompleteRequest do
  describe "#send_request" do
    before(:each) do
      @req = SkyScannerAPI::LocationAutocompleteRequest.new
    end

    it "returns a promise" do
      allow(@req).to receive(:perform_request)
      expect(@req.send_request).to be_a Promise
    end

    it "resolves a promise when request successful" do
      res = Net::HTTPSuccess.new('http', 200, 'test')
      allow(@req).to receive(:perform_request) { res }
      test = double
      expect(test).to receive(:fulfilled).once

      @req.send_request
        .then do |res|
          test.fulfilled
        end
    end

    it "rejects a promise when request unsuccessful" do
      res = Net::HTTPError.new('http', 'test')
      allow(@req).to receive(:perform_request) { res }
      test = double
      expect(test).to receive(:rejected).once

      @req.send_request
        .rescue do |res|
          test.rejected
        end
    end
    it "rejects a promise if params don't pass validation"
  end

  describe "#to_query" do
    before(:each) do
      @req = SkyScannerAPI::LocationAutocompleteRequest.new
    end

    it "creates a correct query string from passed hash" do
      query = {
        test: "testme",
        another: "testme again"
      }
      result = "test=testme&another=testme+again"

      expect(@req.send(:to_query, query)).to eq(result)
    end
  end
end
