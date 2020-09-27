# frozen_string_literal: true

module Gossip
  module Member
    module State
      class BeforePingRequest < Base
        def initialize(id, node_member_id, member_pool, update_entry, target_id)
          @target_id = target_id
          @done = false
          super(id, node_member_id, member_pool, update_entry)
        end

        def advance(_elapsed_seconds)
          if @done then AfterPingRequestBeforeAck.new(@id, @node_member_id, @member_pool, @target_id)
          else self
          end
        end

        def prepare_output
          @done = true
          message = Message.new(@id, @node_member_id, :ping_req, target_id: @target_id)
          [message]
        end

        def health
          'alive'
        end
      end
    end
  end
end
