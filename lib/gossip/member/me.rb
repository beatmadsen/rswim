# frozen_string_literal: true

module Gossip
  module Member
    class Me < Base
      def initialize(id)
        super
        @ack_responder = AckResponder.new(id)
        @incarnation_number = 0
      end

      def schedule_ack(member_id)
        @ack_responder.schedule_ack(member_id)
      end

      def prepare_output
        @ack_responder.prepare_output
      end

      def increment_incarnation_number
        @incarnation_number += 1
      end

      def prepare_update_entry
        UpdateEntry.new(@id, :alive, @incarnation_number)
      end
      
      def update(elapsed_seconds); end
    end
  end
end
