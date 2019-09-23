module Gossip
  class Member
    def initialize(id)
      @state = MemberState::Init.new(id)
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
        @life_time_seconds = 0
      end

      def advance(elapsed_seconds)
        @life_time_seconds += elapsed_seconds
        if @life_time_seconds > 10 then BeforePing.new(@id)
        else self
        end
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
      end

      def advance(elapsed_seconds)
        @life_time_seconds += elapsed_seconds
        if @life_time_seconds > 20 then BeforePing.new(@id)
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
  end
end
