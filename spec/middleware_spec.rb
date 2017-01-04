require 'byebug'
require 'faye/websocket'
require './lib/middleware'

RSpec.describe TravelBot::WebSocketCatcher do
  describe "#call" do
    it "passes the request to the app if it is not a websocket request" do
      allow(Faye::WebSocket).to receive(:websocket?) { false }

      env = {}
      app = double
      expect(app).to receive(:call).with(env)

      TravelBot::WebSocketCatcher.new(app).call(env)
    end

    it "calls process_websocket if it is a websocket request" do
      allow(Faye::WebSocket).to receive(:websocket?) { true }

      env = {}
      catcher = TravelBot::WebSocketCatcher.new({})
      expect(catcher).to receive(:process_websocket).with(env)

      catcher.call(env)
    end
  end

  describe "#process_websocket" do
    before(:each) do
      @socket = double
      allow(@socket).to receive(:send)
      @event = double
      allow(@event).to receive(:data) { "testme" }
      allow(@event).to receive(:code) { "testme" }
      allow(@event).to receive(:reason) { "testme" }
    end

    it "creates a new chat client on open" do
      catcher = TravelBot::WebSocketCatcher.new({})
      catcher.on_socket_open(@socket, @event)
      expect(catcher.clients.length).to eq(1)
    end

    it "sends .start message to chat" do
      chat = double
      expect(chat).to receive(:start)
      allow(TravelBot::Chat).to receive(:new) { chat }

      catcher = TravelBot::WebSocketCatcher.new({})
      catcher.on_socket_open(@socket, @event)
    end

    it "pushes a message to a chat on message" do
      chat = double
      allow(chat).to receive(:start)
      allow(chat).to receive(:push_message) do |msg|
        expect(msg).to eq "testme"
      end
      expect(chat).to receive(:push_message)
      allow(TravelBot::Chat).to receive(:new) { chat }

      catcher = TravelBot::WebSocketCatcher.new({})
      catcher.on_socket_open(@socket, @event)
      catcher.on_socket_message(@socket, @event)
    end

    it "removes client on close" do
      catcher = TravelBot::WebSocketCatcher.new({})
      catcher.on_socket_open(@socket, @event)
      catcher.on_socket_close(@socket, @event)
      expect(catcher.clients.length).to eq(0)
    end
  end
end
