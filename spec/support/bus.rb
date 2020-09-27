# frozen_string_literal: true

class Bus
  def initialize
    @ary = []
  end

  def send(message)
    @ary << message
  end

  def fetch_messages_for(receiver)
    messages = []
    @ary.reject! { |message| messages << message if message.to == receiver }
    messages
  end

  class Pipe
    def initialize(participant, bus)
      @participant = participant
      @bus = bus
    end

    def send(message)
      @bus.send(message)
    end

    def inbound
      @bus.fetch_messages_for(@participant)
    end
  end
end
