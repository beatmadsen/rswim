# frozen_string_literal: true

module Gossip
  module Member
    module State
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
          if @done then Alive.new(@id, @member_pool)
          elsif @life_time_seconds > R_MS / 1000.0 then Suspected.new(@id, @member_pool, true)
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
