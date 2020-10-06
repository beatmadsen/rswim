# frozen_string_literal: true

module RSwim
  class Message
    attr_reader :to, :from, :type, :payload

    def initialize(to, from, type, payload = {})
      @to = to
      @from = from
      @type = type
      @payload = payload
    end

    def to_s
      "message of type #{type} from #{from} to #{to} with #{payload[:updates].to_a.size} updates"
    end
  end
end
