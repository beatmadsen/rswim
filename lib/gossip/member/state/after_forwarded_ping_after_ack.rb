# frozen_string_literal: true

module Gossip
  module Member
    module State
      class AfterForwardedPingAfterAck < Base
        def initialize(id, member_pool, source_id)
          @source_id = source_id
          @done = false
          super(id, member_pool)
        end

        def advance(_elapsed_seconds)
          if @done then Alive.new(@id, @member_pool)
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
  end
  end
end
