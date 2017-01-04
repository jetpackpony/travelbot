require 'json'

module TravelBot
  class Chat
    def initialize(scenario, &send_action)
      @send_action = send_action
      @scenario = scenario
    end

    def start
      respond JSON.generate @scenario.current
    end

    def push_message(msg)
      return if @scenario.complete?
      @scenario.current[:value] =
        case @scenario.current[:type]
        when :text
          search_location msg
        when :select
          parse_option msg
        when :date
          parse_date msg
        end
      @scenario.next
      respond JSON.generate(
        if @scenario.complete?
          { type: :none, label: "Hold on I'll fetch you flight info" }
        else
          @scenario.current
        end
      )
    end

    private
    def respond(msg)
      @send_action.call msg
    end

    def search_location(msg)
      [
        { id: "BCN-sky", name: "Barcelona, Spain" },
        { id: "BLA-sky", name: "Barcelona, Venezuela" }
      ]
    end

    def parse_option(msg)
      msg
    end

    def parse_date(msg)
      msg
    end
  end
end
