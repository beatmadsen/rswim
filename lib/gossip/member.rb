# frozen_string_literal: true

module Gossip
  class Member
    def initialize(id, member_pool)
      @id = id
      @member_pool = member_pool
      @state = MemberState::Init.new(id, member_pool)
    end

    # call this when you wish to send a ping message to member
    def ping
      @state = MemberState::BeforePing.new(@id, @member_pool)
    end

    def ping_request(target_id)
      @state = MemberState::BeforePingRequest.new(@id, @member_pool, target_id)
    end

    def healthy?
      health == 'alive'
    end

    #  call this when you received ack from member
    def replied_with_ack
      @state.member_replied_with_ack
    end

    def forward_ping(source_id)
      @state = MemberState::BeforeForwardedPing.new(@id, @member_pool, source_id)
    end

    def update(elapsed_seconds)
      @state = @state.advance(elapsed_seconds)
    end

    def prepare_output
      @state.prepare_output
    end

    def health
      @state.health
    end
  end
end
