# frozen_string_literal: true

module Gossip
  module Integration
    module Udp
      class Serializer
        def initialize(directory)
          @directory = directory
        end

        def serialize(message); end

        protected

        def logger
          @_logger ||= begin
            Gossip::Logger.new(self.class, STDERR)
          end
        end
      end
    end
  end
end
