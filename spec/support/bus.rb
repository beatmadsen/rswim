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
      message.payload[:bus_to] = message.to
      message.payload[:bus_from] = @participant
      @bus.send(message)
    end

    def inbound
      @bus.fetch_messages_for(@participant).map do |outbound|
        Gossip::Message::Inbound.new(
          outbound.payload[:bus_from],
          outbound.type,
          outbound.payload
        )
      end
    end
  end
end
