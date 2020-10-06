# frozen_string_literal: true

module RSwim
  module Member
    class AckResponder
      def initialize(id)
        @id = id
        @pending = []
      end

      def schedule_ack(member_id)
        @pending << Message.new(member_id, @id, :ack)
      end

      def prepare_output
        result = @pending
        @pending = []
        result
      end
    end
  end
end
