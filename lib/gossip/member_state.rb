module Gossip
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
        elsif @life_time_seconds > 10 then Suspected.new(@id)
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

    class Suspected

      # TODO: need way to acquire k random, healthy members
      def initialize(id)
        @id = id
      end

      def member_replied_with_ack; end

      # TODO: ping other mebers: `other_mebers.each(&:ping)`
      def advance(_elapsed_seconds)
        self
      end

      def prepare_output
        []
      end

      def health
        'suspected'
      end
    end
  end
end
