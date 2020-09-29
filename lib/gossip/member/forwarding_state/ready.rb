# frozen_string_literal: true

module Gossip
  module Member
    module ForwardingState
      class Ready < Base
        def initialize(id, node_member_id)
          super
          @activated = false
        end

        def forward_ack_to_member
          @activated = true
        end

        def member_replied_in_time
          log.debug("out of order ack from member #{@id}")
        end

        def advance(_elapsed_seconds)
          if @activated then AwaitingAck.new(@id, @node_member_id)
          else self
          end
        end
      end
    end
  end
end
