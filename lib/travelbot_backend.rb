require 'faye/websocket'

module TravelBot
  class Backend
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app = app
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

        ws.on :open do |event|
          p [:open, ws.object_id]
        end

        ws.on :message do |event|
          p [:message, event.data]
          data = event.data
          msg = case
          when data.match('how are you')
            'i am great! You?'
          else
            'hey there, beautiful'
          end
          ws.send(msg)
        end

        ws.on :close do |event|
          p [:close, event.code, event.reason]
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
