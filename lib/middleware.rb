require 'faye/websocket'
require 'logger'
require './lib/chat'
require './lib/scenario'

module TravelBot
  class WebSocketCatcher
    KEEPALIVE_TIME = 15 # in seconds

    attr_reader :clients

    def initialize
      @clients = {}
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        process_websocket(env)
      else
        content = 'Not Found'
        [
          404,
          {'Content-Type' => 'text/html', 'Content-Length' => content.size.to_s},
          [content]
        ]
      end
    end

    def process_websocket(env)
      ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
      logger = Logger.new(STDOUT)

      ws.on :open do |event|
        begin
          logger.info(on_socket_open(ws, event, logger))
        rescue Exception => e
          logger.fatal e.message
        end
      end

      ws.on :message do |event|
        begin
          logger.info(on_socket_message(ws, event))
        rescue Exception => e
          logger.fatal e.message
        end
      end

      ws.on :close do |event|
        begin
          logger.info(on_socket_close(ws, event))
          ws = nil
        rescue Exception => e
          logger.fatal e.message
        end
      end
      # Return async Rack response
      ws.rack_response
    end

    def on_socket_open(ws, event, logger)
      chat = Chat.new(TravelBot::Scenario.new, logger) do |msg|
        logger.info([:responding, msg])
        ws.send msg
      end
      chat.start
      @clients[ws.object_id] = chat
      [:open, ws.object_id]
    end

    def on_socket_message(ws, event)
      @clients[ws.object_id].push_message event.data
      [:message, event.data]
    end

    def on_socket_close(ws, event)
      @clients.delete(ws.object_id)
      [:close, event.code, event.reason]
    end
  end
end
