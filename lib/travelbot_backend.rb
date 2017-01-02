require 'faye/websocket'
require './lib/chat'

module TravelBot
  class Backend
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app = app
      @clients = {}
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

        ws.on :open do |event|
          p [:open, ws.object_id]
          @clients[ws.object_id] = Chat.new do |msg|
            ws.send msg
          end
        end

        ws.on :message do |event|
          p [:message, event.data]
          @clients[ws.object_id].push_message event.data
        end

        ws.on :close do |event|
          p [:close, event.code, event.reason]
          @clients.delete(ws.object_id)
          ws = nil
        end

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end
  end
end
