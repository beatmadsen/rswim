# frozen_string_literal: true

module Gossip
  module MemberState

    class Base
      def initialize(id, member_pool)
        logger.debug("Member with id #{id} entered new state")
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

      private

      def logger
        @_logger ||= begin
          Gossip::Logger.new(self.class, STDERR)
        end
      end
    end


    class Init < Base

      def initialize(id, member_pool)
        super
      end

      def health
        'alive'
      end
    end

    class BeforeForwardedPing < Base
      def initialize(id, member_pool, source_id)
        @source_id = source_id
        @done = false
        super(id, member_pool)
      end

      def advance(_elapsed_seconds)
        if @done then AfterForwardedPingBeforeAck.new(@id, @member_pool, @source_id)
        else self
        end
      end

      def prepare_output
        @done = true
        message = Message::Outbound.new(@id, :ping)
        [message]
      end

      def health
        'alive'
      end
    end

    class BeforePing < Base
      def initialize(id, member_pool)
        @done = false
        super
      end

      def member_replied_with_ack; end

      def advance(_elapsed_seconds)
        if @done then AfterPingBeforeAck.new(@id, @member_pool)
        else self
        end
      end

      def prepare_output
        @done = true
        message = Message::Outbound.new(@id, :ping)
        [message]
      end

      def health
        'alive'
      end
    end

    class BeforePingRequest < Base
      def initialize(id, member_pool, target_id)
        @target_id = target_id
        @done = false
        super(id, member_pool)
      end

      def advance(_elapsed_seconds)
        if @done then AfterPingRequestBeforeAck.new(@id, @member_pool, @target_id)
        else self
        end
      end

      def prepare_output
        @done = true
        message = Message::Outbound.new(@id, :ping_req, target_id: @target_id)
        [message]
      end

      def health
        'alive'
      end
    end

    class AfterForwardedPingBeforeAck < Base
      def initialize(id, member_pool, source_id)
        @source_id = source_id
        @life_time_seconds = 0
        @done = false
        super(id, member_pool)
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

      def health
        'awaiting response'
      end
    end

    class AfterForwardedPingAfterAck < Base
      def initialize(id, member_pool, source_id)
        @source_id = source_id
        @done = false
        super(id, member_pool)
      end

      def advance(_elapsed_seconds)
        if @done then Init.new(@id, @member_pool)
        else self
        end
      end

      def prepare_output
        @done = true
        message = Message::Outbound.new(@source_id, :ack)
        [message]
      end

      def health
        'awaiting response'
      end
    end

    class AfterPingBeforeAck < Base
      def initialize(id, member_pool)
        @life_time_seconds = 0
        @done = false
        super
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

      def health
        'awaiting response'
      end
    end

    class AfterPingRequestBeforeAck < Base
      def initialize(id, member_pool, target_id)
        @target_id = target_id
        @life_time_seconds = 0
        @done = false
        super(id, member_pool)
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

      def health
        'alive'
      end
    end

    class Suspected < Base
      def initialize(id, member_pool, send_ping_request)
        @send_ping_request = send_ping_request
        @ping_request_sent = false
        @received_ack = false
        super(id, member_pool)
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

      def health
        'suspected'
      end
    end
  end
end
