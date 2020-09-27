# frozen_string_literal: true

module Gossip
  module Member
    class Peer < Base
      def initialize(id, node_member_id, member_pool)
        super(id)
        @member_pool = member_pool
        @state = State::Alive.new(id, node_member_id, member_pool)
      end

      # call this when you wish to send a ping message to member
      def ping
        @state = @state.transition_on_ping
      end

      def ping_request(target_id)
        @state = @state.transition_on_ping_request(target_id)
      end

      #  call this when you received ack from member
      def replied_with_ack
        @state.member_replied_with_ack
      end

      def forward_ping(source_id)
        @state = @state.transition_on_forward_ping(source_id)
      end

      def update(elapsed_seconds)
        @state = @state.advance(elapsed_seconds)
      end

      def prepare_output
        @state.prepare_output
      end

      def prepare_update_entry
        @state.update_entry
      end

      def increment_propagation_count
        @state.increment_propagation_count
      end

      def update_suspicion(status, incarnation_number)
        @state = @state.update_suspicion(status, incarnation_number)
      end

      def can_be_pinged?
        @state.can_be_pinged?
      end
    end
  end
end
