# frozen_string_literal: true

module Gossip
  module Member
    module State
      class AfterForwardedPingAfterAck < Base
        def initialize(id, node_member_id, member_pool, update_entry, source_id)
          @source_id = source_id
          @done = false
          super(id, node_member_id, member_pool, update_entry)
        end

        def advance(_elapsed_seconds)
          if @done then Alive.new(@id, @node_member_id, @member_pool)
          else self
          end
        end

        def prepare_output
          @done = true
          message = Message.new(@source_id, @node_member_id, :ack)
          [message]
        end

        def health
          'awaiting response'
        end
      end
  end
  end
end
