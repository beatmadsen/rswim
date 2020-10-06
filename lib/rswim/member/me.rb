# frozen_string_literal: true

module RSwim
  module Member
    class Me < Base
      def initialize(id)
        super
        @ack_responder = AckResponder.new(id)
        @incarnation_number = 0
        @propagation_count = 0
      end

      def schedule_ack(member_id)
        @ack_responder.schedule_ack(member_id)
      end

      def prepare_output
        @ack_responder.prepare_output
      end

      def update_suspicion(status, incarnation_number)
        if status != :alive && incarnation_number == @incarnation_number
          @incarnation_number += 1

          # making sure to get priority in being propagated
          @propagation_count = -10
        end
      end

      def increment_propagation_count
        @propagation_count += 1
      end

      def prepare_update_entry
        UpdateEntry.new(@id, :alive, @incarnation_number, @propagation_count)
      end

      def update(elapsed_seconds); end

      def can_be_pinged?
        false
      end
    end
  end
end
