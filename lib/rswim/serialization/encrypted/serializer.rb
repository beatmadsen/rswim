# frozen_string_literal: true

module RSwim
  module Serialization::Encrypted
    class Serializer
      def initialize(directory)
        @directory = directory
      end

      def serialize(message)
        unencrypted = serialize_unencrypted(message)
        cipher_text, salt = Encryption.encrypt(unencrypted).map { |s| Base64.encode64(s) }
        { message: cipher_text, salt: salt }.to_json
      end

      protected

      def logger
        @_logger ||= RSwim::Logger.new(self.class, STDERR)
      end

      private

      def serialize_unencrypted(message)
        out = {}
        out[:type] = message.type
        out[:target] = @directory.host(message.payload[:target_id]) if message.type == :ping_req
        out[:updates] = message.payload[:updates].to_a.map do |update|
          {
            host: @directory.host(update.member_id),
            status: update.status,
            incarnation_number: update.incarnation_number,
            custom_state: update.custom_state
          }
        end

        out.to_json
      end
    end
  end
end
