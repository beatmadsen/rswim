# frozen_string_literal: true

class SimulatedPauseAgent < RSwim::Agent::FiberBased
  attr_writer :next_pause_seconds

  def initialize(pipe, node_member_id, seed_member_ids)
    super(pipe, node_member_id, seed_member_ids, RSwim::T_MS, RSwim::R_MS)
    @next_pause_seconds = 0.5
  end

  protected

  def new_protocol_state(node_member_id, seed_member_ids, t_ms, r_ms)
    TestProtocolState.new(node_member_id, seed_member_ids, t_ms, r_ms)
  end

  def pause
    Fiber.yield
    @next_pause_seconds.to_f
  end

  class TestProtocolState < RSwim::ProtocolState
    attr_reader :member_pool

    protected

    def new_member_pool(node_member_id, seed_member_ids)
      TestMemberPool.new(node_member_id, seed_member_ids)
    end
  end

  class TestMemberPool < RSwim::MemberPool
    protected

    def random_member(members)
      members.last
    end
  end
end
