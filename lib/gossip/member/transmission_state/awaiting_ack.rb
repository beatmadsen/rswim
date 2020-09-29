# frozen_string_literal: true

module Gossip
  module Member
    module TransmissionState
      class AwaitingAck < Base
        def initialize(id, node_member_id, member_pool, source_ids, target_ids)
          super
          @life_time_seconds = 0
          @done = false
        end

        def member_replied_with_ack
          if @source_ids.include?(@id)
            @member_pool.member_replied_in_time(@id)
          end
          @source_ids.each { |i| @member_pool.forward_ack_to(i) unless i == @id }
          @source_ids.clear
          @done = true
        end

        def advance(elapsed_seconds)
          @life_time_seconds += elapsed_seconds
          if @done
            Ready.new(@id, @node_member_id, @member_pool, @source_ids, @target_ids)
          elsif @life_time_seconds > R_MS / 1000.0
            if @source_ids.include?(@id)
              @member_pool.failed_to_reply(@id)
            end
            Ready.new(@id, @node_member_id, @member_pool, @source_ids, @target_ids)
          else
            self
          end
        end
      end
    end
  end
end
