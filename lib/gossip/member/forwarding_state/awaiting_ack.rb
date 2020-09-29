# frozen_string_literal: true

module Gossip
  module Member
    module ForwardingState
      class AwaitingAck < Base
        def initialize(id, node_member_id)
          super
          @done = false
          @success = false
        end

        def member_replied_in_time
          @done = true
          @success = true
        end

        def reset
          @done = true
          @success = false
        end

        def advance(_elapsed_seconds)
          if @done
            if @success
              ForwardingAck.new(@id, @node_member_id)
            else
              Ready.new(@id, @node_member_id)
            end
          else
            self
          end
        end
      end
    end
  end
end
