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

      # call this when you wish to send a ping message to member
      def ping
        @state = @state.transition_on_ping
      end

      # send ping request to this member
      def ping_request(target_id)
        @state = @state.transition_on_ping_request(target_id)
      end

      # when node receives a ping request from source towards peer
      def forward_ping(source_id)
        @state = @state.transition_on_forward_ping(source_id)
      end

      #  call this when you received ack from member
      def replied_with_ack
        # TODO: update both health and transmission accordingly
        @transmission_state.member_replied_with_ack
      end

      def replied_in_time
        update_suspicion(:alive)        
      end

      def failed_to_reply
        update_suspicion(:suspected)
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

      def update_suspicion(status, incarnation_number=nil)
        @state = @state.update_suspicion(status, incarnation_number)
      end

      def can_be_pinged?
        @state.can_be_pinged?
      end
    end
  end
end
