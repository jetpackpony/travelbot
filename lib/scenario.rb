module TravelBot
  class Scenario
    def initialize
      @questions = [
        {
          name: "to-location-text",
          type: :text,
          label: "Where are you flying to?",
          value: ""
        },
        {
          name: "to-location-select",
          type: :select,
          label: "Which city?",
          options: [],
          value: nil
        },
        {
          id: "departure-date",
          type: :date,
          question: "When would you like to go?",
          value: nil
        },
        {
          name: "from-location-text",
          type: :text,
          label: "Where are you flying from?",
          value: ""
        },
        {
          name: "from-location-select",
          type: :select,
          label: "Which city?",
          options: [],
          value: nil
        },
      ]
      @position = 0
    end

    def current
      @questions[@position]
    end

    def set_value=(value)
      current[:value] = value
      self.next
    end

    def next
      @position += 1
      return current if complete?
      prepare
      current
    end

    def prepare
      if current[:type] == :select
        current[:options] = @questions[@position - 1][:value]
      end
    end

    def complete?
      @position >= @questions.length
    end

    def from
      @questions.find { |i| i[:id] === "from-location-select" }[:value]
    end

    def to
      @questions.find { |i| i[:id] === "to-location-select" }[:value]
    end

    def date
      @questions.find { |i| i[:id] === "departure-date" }[:value]
    end

    def request
      [from, to, date]
    end
  end
end
