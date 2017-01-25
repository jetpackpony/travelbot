module TravelBot
  class Scenario
    DEFAULT_QUESTIONS = [
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
        name: "departure-date",
        type: :date,
        label: "When would you like to go?",
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

    def initialize(questions = DEFAULT_QUESTIONS)
      @questions = questions
      @position = 0
    end

    def current
      @questions[@position]
    end

    def set_value=(value)
      current[:value] = value
      self.next
    end

    def get_question_by_name(name)
      @questions.find { |i| i[:name] == name }
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
      get_question_by_name("from-location-select")[:value]
    end

    def to
      get_question_by_name("to-location-select")[:value]
    end

    def date
      get_question_by_name("departure-date")[:value]
    end

    def request
      complete? ? [from, to, date] : false
    end

    def results_label
      "Here are the cheapest flights from #{from[:name]} to #{to[:name]} for #{date}"
    end
  end
end
