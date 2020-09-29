# frozen_string_literal: true

module Gossip
  module Member
    module ForwardingState
      class Base
        def initialize(id, node_member_id)
          logger.debug("Member with id #{id} entered new state: #{self.class}")
          @member_pool = member_pool
          # We are forwarding acks to this member
          @id = id
          @node_member_id = node_member_id
        end

        def forward_ack_to_member; end

        def advance(_elapsed_seconds)
          self
        end

        def prepare_output
          []
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
