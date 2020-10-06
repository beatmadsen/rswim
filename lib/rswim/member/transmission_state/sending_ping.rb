# frozen_string_literal: true

module RSwim
  module Member
    module TransmissionState
      class SendingPing < Base
        def initialize(id, node_member_id, member_pool, source_ids, target_ids)
          super
          @done = false
        end

        def member_replied_with_ack
          logger.debug("out of order ack from member #{@id}")
        end

        def advance(_elapsed_seconds)
          if @done then AwaitingAck.new(@id, @node_member_id, @member_pool, @source_ids, @target_ids)
          else self
          end
        end

        def prepare_output
          @done = true
          message = Message.new(@id, @node_member_id, :ping)
          [message]
        end
      end
    end
  end
end
