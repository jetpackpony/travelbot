module TravelBot
  class Chat
    def initialize(&send_action)
      @send_action = send_action
    end

    def push_message(msg)
      respond "Receieved from you: #{msg}"
    end

    private
    def respond(msg)
      @send_action.call msg
    end
  end
end
