# frozen_string_literal: true

module RSwim
  module Integration
    class Serializer
      def initialize(directory)
        @directory = directory
      end

      def serialize(message)
        l1 = message.type.to_s.gsub(/_/, '-')
        l1 << " #{@directory.host(message.payload[:target_id])}" if message.type == :ping_req

        message.payload[:updates].to_a.each do |update|
          # host status incarnation_number
          l1 << "\n#{@directory.host(update.member_id)} #{update.status} #{update.incarnation_number}"
          l1 << " #{serialize_custom_state(update.custom_state)}" unless update.custom_state.empty?
        end
        l1
      end

      protected

      def logger
        @_logger ||= RSwim::Logger.new(self.class, STDERR)
      end

      private

      def serialize_custom_state(custom_state)
        custom_state.map { |k, v| "#{k}: #{v}" }.join(' ')
      end
    end
  end
end
