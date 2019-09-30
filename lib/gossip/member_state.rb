# frozen_string_literal: true

module Gossip
  module MemberState
    class Init
      def initialize(id, member_pool)
        @member_pool = member_pool
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

    class BeforeForwardedPing
      def initialize(id, member_pool, source_id)
        @member_pool = member_pool
        @id = id
        @source_id = source_id
        @done = false
      end

      def member_replied_with_ack; end

      def advance(_elapsed_seconds)
        if @done then AfterForwardedPingBeforeAck.new(@id, @member_pool, @source_id)
        else self
        end
      end

      def prepare_output
        @done = true
        [[@id, 'ping']]
      end

      def health
        'alive'
      end
    end

    class BeforePing
      def initialize(id, member_pool)
        @member_pool = member_pool
        @id = id
        @done = false
      end

      def member_replied_with_ack; end

      def advance(_elapsed_seconds)
        if @done then AfterPingBeforeAck.new(@id, @member_pool)
        else self
        end
      end

      def prepare_output
        @done = true
        [[@id, 'ping']]
      end

      def health
        'alive'
      end
    end

    class BeforePingRequest
      def initialize(id, member_pool, target_id)
        @id = id
        @member_pool = member_pool
        @target_id = target_id
        @done = false
      end

      def member_replied_with_ack; end

      def advance(_elapsed_seconds)
        if @done then AfterPingRequestBeforeAck.new(@id, @member_pool, @target_id)
        else self
        end
      end

      def prepare_output
        @done = true
        [[@id, "ping-req #{@target_id}"]]
      end

      def health
        'alive'
      end
    end

    class AfterForwardedPingBeforeAck
      def initialize(id, member_pool, source_id)
        @member_pool = member_pool
        @id = id
        @source_id = source_id
        @life_time_seconds = 0
        @done = false
      end

      def member_replied_with_ack
        @done = true
      end

      def advance(elapsed_seconds)
        @life_time_seconds += elapsed_seconds
        if @done then AfterForwardedPingAfterAck.new(@id, @member_pool, @source_id)
        elsif @life_time_seconds > R_MS / 1000.0 then Suspected.new(@id, @member_pool, false)
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

    class AfterForwardedPingAfterAck
      def initialize(id, member_pool, source_id)
        @member_pool = member_pool
        @id = id
        @source_id = source_id
        @done = false
      end

      def member_replied_with_ack; end

      def advance(_elapsed_seconds)
        if @done then Init.new(@id, @member_pool)
        else self
        end
      end

      def prepare_output
        @done = true
        [[@source_id, 'ack']]
      end

      def health
        'awaiting response'
      end
    end

    class AfterPingBeforeAck
      def initialize(id, member_pool)
        @member_pool = member_pool
        @id = id
        @life_time_seconds = 0
        @done = false
      end

      def member_replied_with_ack
        @done = true
      end

      def advance(elapsed_seconds)
        @life_time_seconds += elapsed_seconds
        if @done then Init.new(@id, @member_pool)
        elsif @life_time_seconds > R_MS / 1000.0 then Suspected.new(@id, @member_pool, true)
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

    class AfterPingRequestBeforeAck
      def initialize(id, member_pool, target_id)
        @id = id
        @member_pool = member_pool
        @target_id = target_id
        @life_time_seconds = 0
        @done = false
      end

      def member_replied_with_ack
        @member_pool.indirect_ack(@target_id)
        @done = true
      end

      def advance(elapsed_seconds)
        @life_time_seconds += elapsed_seconds
        if @done || @life_time_seconds > R_MS / 1000.0 then Init.new(@id, @member_pool)
        else self
        end
      end

      def prepare_output
        []
      end

      def health
        'alive'
      end
    end

    class Suspected
      def initialize(id, member_pool, send_ping_request)
        @member_pool = member_pool
        @id = id
        @send_ping_request = send_ping_request
        @ping_request_sent = false
        @received_ack = false
      end

      def member_replied_with_ack
        @received_ack = true
      end

      def advance(_elapsed_seconds)
        if @received_ack
          Init.new(@id, @member_pool)
        else
          if @send_ping_request && !@ping_request_sent
            @member_pool.ping_request_to_k_members(@id)
            @ping_request_sent = true
          end
          self
        end
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
