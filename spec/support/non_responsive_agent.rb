# frozen_string_literal: true

class NonResponsiveAgent < Gossip::Agent::FiberBased
  attr_writer :next_pause_seconds

  def initialize(pipe)
    @pipe = pipe
    @state = NonResponsiveProtocolState.new
  end

  protected

  def pause
    Fiber.yield
    @next_pause_seconds.to_f
  end

  class NonResponsiveProtocolState
    def advance(input_messages, elapsed_seconds)
      []
    end
  end
end
