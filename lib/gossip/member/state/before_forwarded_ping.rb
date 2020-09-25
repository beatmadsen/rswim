# frozen_string_literal: true

module Gossip
  module Member
    module State
      class BeforeForwardedPing < Base
        def initialize(id, member_pool, source_id)
          @source_id = source_id
          @done = false
          super(id, member_pool)
        end

        def advance(_elapsed_seconds)
          if @done then AfterForwardedPingBeforeAck.new(@id, @member_pool, @source_id)
          else self
          end
        end

        def prepare_output
          @done = true
          message = Message::Outbound.new(@id, :ping)
          [message]
        end

        def health
          'alive'
        end
      end
    end
  end
end
