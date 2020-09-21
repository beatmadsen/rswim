# frozen_string_literal: true

module Gossip
  class Message
    attr_reader :type, :payload

    def initialize(type, payload)
      @type = type
      @payload = payload
    end

    class Outbound < Message
      attr_reader :to

      def initialize(to, type, payload = {})
        @to = to
        super(type, payload)
      end
    end

    class Inbound < Message
      attr_reader :from

      def initialize(from, type, payload = {})
        @from = from
        super(type, payload)
      end
    end
  end
end
