# frozen_string_literal: true

module Gossip
  module Member
    module State
      class AfterPingRequestBeforeAck < Base
        def initialize(id, node_member_id, member_pool, update_entry, target_id)
          @target_id = target_id
          @life_time_seconds = 0
          @done = false
          super(id, node_member_id, member_pool, update_entry)
        end

        def member_replied_with_ack
          @member_pool.indirect_ack(@target_id)
          @done = true
        end

        def advance(elapsed_seconds)
          @life_time_seconds += elapsed_seconds
          if @done || @life_time_seconds > R_MS / 1000.0 then Alive.new(@id, @node_member_id, @member_pool, @update_entry)
          else self
          end
        end

        def health
          'alive'
        end
      end
    end
  end
end
