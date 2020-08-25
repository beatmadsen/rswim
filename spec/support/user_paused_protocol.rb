# frozen_string_literal: true

class UserPausedProtocol < Gossip::Protocol::FiberBased
  attr_writer :next_pause_seconds

  protected

  def pause
    Fiber.yield
    @next_pause_seconds
  end
end
