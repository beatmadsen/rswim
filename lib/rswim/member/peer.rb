# frozen_string_literal: true

module RSwim
  module Member
    class Peer < Base
      def initialize(id, node_member_id, member_pool)
        super(id)
        @member_pool = member_pool
        @node_member_id = node_member_id
        @transmission_state = TransmissionState::Ready.new(id, node_member_id, member_pool)
        @health_state = HealthState::Alive.new(id, node_member_id, member_pool)
        @forwarding_state = ForwardingState::Ready.new(id, node_member_id)
        @custom_state_holder = CustomStateHolder.new(id, node_member_id)
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

      # # Callbacks

      #  call this when you received ack from member
      def replied_with_ack
        @transmission_state.member_replied_with_ack
      end

      def replied_in_time
        update_suspicion(:alive)
      end

      def failed_to_reply
        @health_state.member_failed_to_reply
      end

      ## Commands

      def halt
        @transmission_state = TransmissionState::Off.new(@id, @node_member_id)
      end

      def forward_ack
        @forwarding_state.forward_ack_to_member
      end

      def update(elapsed_seconds)
        @transmission_state = @transmission_state.advance(elapsed_seconds)
        @forwarding_state = @forwarding_state.advance(elapsed_seconds)
        @health_state = @health_state.advance(elapsed_seconds)
      end

      def increment_propagation_count
        @health_state.increment_propagation_count
        @custom_state_holder.increment_propagation_count
      end

      def prepare_output
        [@transmission_state, @forwarding_state].flat_map(&:prepare_output)
      end

      def prepare_update_entry
        pc = [@health_state, @custom_state_holder].map!(&:propagation_count).min
        UpdateEntry.new(@id, @health_state.status, @incarnation_number, @custom_state_holder.state, pc)
      end

      def incorporate_gossip(update_entry)
        update_custom_state(update_entry.custom_state, update_entry.incarnation_number)
        update_suspicion(update_entry.status, update_entry.incarnation_number)
        @incarnation_number = update_entry.incarnation_number if update_entry.incarnation_number > @incarnation_number
      end

      def can_be_pinged?
        @health_state.can_be_pinged?
      end

      private

      def update_custom_state(new_state, incarnation_number)
        should_update = new_state != @custom_state_holder.state && incarnation_number > @incarnation_number
        @custom_state_holder.state = new_state if should_update
      end


      def update_suspicion(status, incarnation_number = nil)
        old_incarnation_number = @incarnation_number
        incarnation_number ||= @incarnation_number
        @health_state = @health_state.update_suspicion(status, old_incarnation_number, incarnation_number)
      end

      class CustomStateHolder
        attr_reader :propagation_count, :state

        def initialize(id, node_member_id)
          @id = id
          @node_member_id = node_member_id
          @state = {}
          @propagation_count = 0
        end

        def state=(arg)
          @state = arg
          @propagation_count = 0
          logger.debug("Member with id #{@id} updated custom state: #{@state}")
        end

        def increment_propagation_count
          @propagation_count += 1
        end

        def logger
          @_logger ||= RSwim::Logger.new("Node #{@node_member_id}", $stderr)
        end
      end
    end
  end
end
