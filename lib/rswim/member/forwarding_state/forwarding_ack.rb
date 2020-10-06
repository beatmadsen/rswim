# frozen_string_literal: true

module RSwim
  module Member
    module ForwardingState
      class ForwardingAck < Base
        def initialize(id, node_member_id)
          super
          @done = false
        end

        def prepare_output
          @done = true
          message = Message.new(@id, @node_member_id, :ack)
          [message]
        end

        def advance(elapsed_seconds)
          if @done then Ready.new(@id, @node_member_id)
          else self
          end
        end
      end
    end
  end
end
