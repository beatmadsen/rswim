# frozen_string_literal: true

module RSwim
  module Member
    # Member behaviour of local node ("me")
    class Me < Base
      def initialize(id)
        super
        @ack_responder = AckResponder.new(id)
        @propagation_count = 0
        @custom_state = {}
      end

      def increment_propagation_count
        @propagation_count += 1
      end

      def schedule_ack(member_id)
        @ack_responder.schedule_ack(member_id)
      end

      def prepare_output
        @ack_responder.prepare_output
      end

      def append_custom_state(key, value)
        @custom_state[key] = value
        propagate_change
      end

      def incorporate_gossip(update_entry)
        if update_entry.incarnation_number >= @incarnation_number &&
           (update_entry.status != :alive || update_entry.custom_state != @custom_state)
          propagate_change
        end
      end

      def prepare_update_entry
        UpdateEntry.new(@id, :alive, @incarnation_number, @custom_state, @propagation_count)
      end

      def update(elapsed_seconds); end

      def can_be_pinged?
        false
      end

      private

      def propagate_change
        @incarnation_number += 1

        # making sure to get priority in being propagated
        @propagation_count = -10
      end
    end
  end
end
