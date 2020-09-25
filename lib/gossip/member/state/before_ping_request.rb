# frozen_string_literal: true

module Gossip
  module Member
    module State
      class BeforePingRequest < Base
        def initialize(id, member_pool, target_id)
          @target_id = target_id
          @done = false
          super(id, member_pool)
        end

        def advance(_elapsed_seconds)
          if @done then AfterPingRequestBeforeAck.new(@id, @member_pool, @target_id)
          else self
          end
        end

        def prepare_output
          @done = true
          message = Message::Outbound.new(@id, :ping_req, target_id: @target_id)
          [message]
        end

        def health
          'alive'
        end
      end
    end
  end
end
