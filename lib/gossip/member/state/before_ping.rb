# frozen_string_literal: true

module Gossip
  module Member
    module State
      class BeforePing < Base
        def initialize(id, node_member_id, member_pool, update_entry)
          @done = false
          super
        end

        def member_replied_with_ack; end

        def advance(_elapsed_seconds)
          if @done then AfterPingBeforeAck.new(@id, @node_member_id, @member_pool)
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
