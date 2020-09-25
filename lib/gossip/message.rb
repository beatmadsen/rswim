# frozen_string_literal: true

module Gossip
  class Message
    attr_reader :to, :from, :type, :payload

    def initialize(to, from, type, payload = {})
      @to = to
      @from = from
      @type = type
      @payload = payload
    end
  end
end
