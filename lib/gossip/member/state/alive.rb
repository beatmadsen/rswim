# frozen_string_literal: true

module Gossip
  module Member
    module State
      class Alive < Base
        def initialize(id, node_member_id, member_pool, update_entry = nil)
          if update_entry.nil?
            ue = UpdateEntry.new(id, :alive, 0, 0)
            super(id, node_member_id, member, ue)
          elsif update_entry.status == :alive
            super
          else
            ue = UpdateEntry.new(id, :alive, update_entry.incarnation_number, 0)
            super(id, node_member_id, member, ue)
          end
        end

        def health
          'alive'
        end

        def update_suspicion(status, incarnation_number)
          self # TODO
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

        private

        def init_update_entry
          UpdateEntry.new(@id)
        end
      end
    end
  end
end
