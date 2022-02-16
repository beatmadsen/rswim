# frozen_string_literal: true

module RSwim
  module Serialization::Encrypted
    class Deserializer
      def initialize(directory, my_id)
        @directory = directory
        @my_id = my_id
      end

      def deserialize(sender_host, wire_message)
        outer = JSON.parse(wire_message)
        cipher_text, salt = outer.values_at('message', 'salt').map { |s| Base64.decode64(s) }
        inner = JSON.parse(Encryption.decrypt(cipher_text, salt), symbolize_names: true)

        from = @directory.id(sender_host)
        payload = {}
        payload[:target_id] = @directory.id(inner[:target]) unless inner[:target].nil?
        payload[:updates] = inner[:updates].to_a.map do |u|
          UpdateEntry.new(
            @directory.id(u[:host]),
            u[:status].to_sym,
            u[:incarnation_number].to_i,
            u[:custom_state]
          )
        end
        Message.new(@my_id, from, inner[:type].to_sym, payload)
      rescue StandardError => e
        logger.debug("Failed to parse wire message")
        nil
      end

      protected

      def logger
        @_logger ||= RSwim::Logger.new(self.class, $stderr)
      end
    end
  end
end
