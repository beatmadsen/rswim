# frozen_string_literal: true

module RSwim
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
        RSwim::Message.new(@my_id, from, type, payload)
      rescue StandardError => e
        logger.debug("Failed to parse line `#{l}`: #{e}")
        nil
      end

      protected

      def logger
        @_logger ||= RSwim::Logger.new(self.class, $stderr)
      end

      private

      def parse_updates(lines)
        lines.map do |l|
          # host status incarnation_number
          host, status, incarnation_number, *pairs = l.strip.split(' ')
          id = @directory.id(host)
          custom_state = parse_custom_state(pairs)

          UpdateEntry.new(id, status.to_sym, incarnation_number.to_i, custom_state)
        rescue StandardError => e
          logger.debug("Failed to parse line `#{l}`: #{e}")
          nil
        end.tap(&:compact!)
      end

      def parse_custom_state(pairs)
        pairs.each_slice(2).map do |(key, value)|
          raise 'bad custom state' if !key.end_with?(':') || value.nil?

          [key[0..-2].to_sym, value]
        end.to_h
      end
    end
  end
end
