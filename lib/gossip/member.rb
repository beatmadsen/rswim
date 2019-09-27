module Gossip
  class Member
    def initialize(id)
      @id  = id
      @state = MemberState::Init.new(id)
    end

    # call this when you wish to send a ping message to member
    def ping
      @state = MemberState::BeforePing.new(@id)
    end

    def healthy?
      health == 'up' || health == 'alive'
    end

    #  call this when you received ack from member
    def replied_with_ack
      @state.member_replied_with_ack
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
