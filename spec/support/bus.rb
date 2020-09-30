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

  class IntermittentPipe < Pipe
    def initialize(participant, bus)
      super
      @i = 0
    end

    def send(message)
      @i += 1
      super if @i % 9 < 2
    end

    def inbound
      @i += 1
      if @i % 9 < 2 then super
      else []
      end
    end
  end
end
