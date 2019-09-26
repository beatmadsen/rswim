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

  module MemberState
    class Init
      def initialize(id)
        @id = id
      end

      def member_replied_with_ack; end

      def advance(elapsed_seconds)
        self
      end

      def prepare_output
        []
      end

      def health
        'up'
      end
    end

    class BeforePing
      def initialize(id)
        @id = id
        @done = false
      end

      def member_replied_with_ack; end

      def advance(_elapsed_seconds)
        if @done then AfterPingBeforeAck.new(@id)
        else self
        end
      end

      def prepare_output
        @done = true
        [[@id, 'ping']]
      end

      def health
        'up'
      end
    end

    class AfterPingBeforeAck
      def initialize(id)
        @id = id
        @life_time_seconds = 0
        @done = false
      end

      def member_replied_with_ack
        @done = true
      end

      def advance(elapsed_seconds)
        @life_time_seconds += elapsed_seconds
        if @done then AfterAck.new(@id)
        elsif @life_time_seconds > 20 then BeforePing.new(@id)
        else self
        end
      end

      def prepare_output
        []
      end

      def health
        'awaiting response'
      end
    end

    class AfterAck
      def initialize(id)
        @id = id
      end

      def member_replied_with_ack; end

      def advance(_elapsed_seconds)
        self
      end

      def prepare_output
        []
      end

      def health
        'alive'
      end
    end
  end
end
