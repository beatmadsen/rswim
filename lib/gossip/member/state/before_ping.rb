# frozen_string_literal: true

module Gossip
  module Member
    module State
      class BeforePing < Base
        def initialize(id, member_pool)
          @done = false
          super
        end

        def member_replied_with_ack; end

        def advance(_elapsed_seconds)
          if @done then AfterPingBeforeAck.new(@id, @member_pool)
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
