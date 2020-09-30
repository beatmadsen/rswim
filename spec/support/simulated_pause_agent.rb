# frozen_string_literal: true

class SimulatedPauseAgent < Gossip::Agent::FiberBased
  attr_writer :next_pause_seconds

  def initialize(pipe, node_member_id, seed_member_ids)
    super(pipe, node_member_id, seed_member_ids, Gossip::T_MS, Gossip::R_MS)
    @next_pause_seconds = 0.5
  end

  protected

  def pause
    Fiber.yield
    @next_pause_seconds.to_f
  end
end
