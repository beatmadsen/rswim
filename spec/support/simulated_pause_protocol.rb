# frozen_string_literal: true

class SimulatedPauseProtocol < Gossip::Protocol::FiberBased
  attr_writer :next_pause_seconds

  def initialize(pipe, seed_member_ids)
    super(pipe, seed_member_ids, Gossip::T_MS, Gossip::R_MS)
    @next_pause_seconds = 0.1
  end

  protected

  def pause
    Fiber.yield
    @next_pause_seconds.to_f
  end
end
