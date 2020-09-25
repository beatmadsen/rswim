# frozen_string_literal: true

module Gossip
  module Member
    module State
      class Suspected < Base
        def initialize(id, member_pool, send_ping_request)
          @send_ping_request = send_ping_request
          @ping_request_sent = false
          @received_ack = false
          super(id, member_pool)
        end

        def member_replied_with_ack
          @received_ack = true
        end

        def advance(_elapsed_seconds)
          if @received_ack
            Alive.new(@id, @member_pool)
          else
            if @send_ping_request && !@ping_request_sent
              @member_pool.ping_request_to_k_members(@id)
              @ping_request_sent = true
            end
            self
          end
        end

        def health
          'suspected'
        end
      end
    end
  end
end
