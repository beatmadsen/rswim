# frozen_string_literal: true

class SimulatedPauseAgent < RSwim::Agent::FiberBased
  attr_writer :next_pause_seconds

  def initialize(pipe, node_member_id, seed_member_ids)
    super(pipe, node_member_id, seed_member_ids, RSwim::T_MS, RSwim::R_MS)
    @next_pause_seconds = 0.5
  end

  protected

  def pause
    Fiber.yield
    @next_pause_seconds.to_f
  end
end
