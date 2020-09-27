# frozen_string_literal: true

module Gossip
  module Member
    module State
      class Suspected < Base
        def initialize(id, node_member_id, member_pool, update_entry, send_ping_request)
          @send_ping_request = send_ping_request
          @ping_request_sent = false
          @received_ack = false
          ue = update_entry.status == :suspected ? update_entry :
                 UpdateEntry.new(id, :suspected, update_entry.incarnation_number, 0)

          super(id, node_member_id, member_pool, ue)
        end

        def member_replied_with_ack
          @received_ack = true
        end

        def advance(_elapsed_seconds)
          if @received_ack
            Alive.new(@id, @node_member_id, @member_pool)
          else
            if @send_ping_request && !@ping_request_sent
              @member_pool.ping_request_to_k_members(@id)
              @ping_request_sent = true
            end
            self
          end
        end

        def transition_on_ping
          State::BeforePing.new(@id, @node_member_id, @member_pool, @update_entry)
        end

        def transition_on_ping_request(target_id)
          State::BeforePingRequest.new(@id, @node_member_id, @member_pool, @update_entry, target_id)
        end

        def transition_on_forward_ping(source_id)
          State::BeforeForwardedPing.new(@id, @node_member_id, @member_pool, @update_entry, source_id)
        end
      end
    end
  end
end
