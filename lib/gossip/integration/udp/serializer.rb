# frozen_string_literal: true

module Gossip
  module Integration
    module Udp
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
          end
          l1
        end

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