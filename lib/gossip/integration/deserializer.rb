# frozen_string_literal: true

module Gossip
  module Integration
    class Deserializer
      def initialize(directory, my_id)
        @directory = directory
        @my_id = my_id
      end

      def deserialize(sender_host, wire_message)
        l, *ls = wire_message.split("\n")
        # First line is
        # type [target_id]
        ary = l.strip.split(' ')
        type = ary[0].gsub(/-/, '_').to_sym
        payload = type == :ping_req ? { target_id: @directory.id(ary[1]) } : {}
        payload[:updates] = parse_updates(ls)
        from = @directory.id(sender_host)
        Gossip::Message.new(@my_id, from, type, payload)
      rescue StandardError => e
        logger.debug("Failed to parse line `#{l}`: #{e}")
        nil
      end

      protected

      def logger
        @_logger ||= begin
          Gossip::Logger.new(self.class, STDERR)
        end
      end

      private

      def parse_updates(lines)
        lines.map do |l|
          begin
            # host status incarnation_number
            host, status, incarnation_number = l.strip.split(' ')
            id = @directory.id(host)
            UpdateEntry.new(id, status.to_sym, incarnation_number.to_i)
          rescue StandardError => e
            logger.debug("Failed to parse line `#{l}`: #{e}")
            nil
          end
        end.tap(&:compact!)
      end
    end
  end
end
