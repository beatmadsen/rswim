# frozen_string_literal: true

module Gossip
  module Member
    class Peer < Base
      def initialize(id, node_member_id, member_pool)
        super(id)
        @member_pool = member_pool
        @transmission_state = TransmissionState::Ready.new(id, node_member_id, member_pool)
        @health_state = HealthState::Alive.new(id, node_member_id, member_pool)
        @forwarding_state = ForwardingState::Ready.new(id, node_member_id)
      end

      ## Messages

      # send a ping message to this peer
      def ping!
        @transmission_state.enqueue_ping
      end

      # send ping request to this peer trying to reach target with target_id
      def ping_request!(target_id)
        @transmission_state.enqueue_ping_request(target_id)
      end

      # send a ping message to this peer on behalf of source with source_id
      def ping_from!(source_id)
        @transmission_state.enqueue_ping_from(source_id)
      end


      ## Callbacks

      #  call this when you received ack from member
      def replied_with_ack
        @transmission_state.member_replied_with_ack
      end

      def replied_in_time
        update_suspicion(:alive)
      end

      def failed_to_reply
        update_suspicion(:suspected)
      end

      def forward_ack
        @forwarding_state.forward_ack_to_member
      end

      def update(elapsed_seconds)
        @transmission_state = @transmission_state.advance(elapsed_seconds)
        @forwarding_state = @forwarding_state.advance(elapsed_seconds)
        @health_state = @health_state.advance(elapsed_seconds)
      end

      def prepare_output
        [@transmission_state, @forwarding_state].flat_map(&:prepare_output)
      end

      def prepare_update_entry
        @health_state.update_entry
      end

      def increment_propagation_count
        @health_state.increment_propagation_count
      end

      def update_suspicion(status, incarnation_number=nil)
        @health_state = @health_state.update_suspicion(status, incarnation_number)
      end

      def can_be_pinged?
        @health_state.can_be_pinged?
      end
    end
  end
end
