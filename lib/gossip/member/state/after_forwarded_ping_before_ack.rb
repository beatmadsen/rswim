# frozen_string_literal: true

module Gossip
  module Member
    module State
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
    end
  end
end
