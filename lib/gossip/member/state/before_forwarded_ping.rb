# frozen_string_literal: true

module Gossip
  module Member
    module State
      class BeforeForwardedPing < Base
        def initialize(id, node_member_id, member_pool, update_entry, source_id)
          @source_id = source_id
          @done = false
          super(id, node_member_id, member_pool, update_entry)
        end

        def advance(_elapsed_seconds)
          if @done then AfterForwardedPingBeforeAck.new(@id, @node_member_id, @member_pool, @source_id)
          else self
          end
        end

        def prepare_output
          @done = true
          message = Message.new(@id, @node_member_id, :ping)
          [message]
        end

        def health
          'alive'
        end
      end
    end
  end
end
