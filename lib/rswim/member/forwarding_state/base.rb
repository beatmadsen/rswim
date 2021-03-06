# frozen_string_literal: true

module RSwim
  module Member
    module ForwardingState
      class Base
        def initialize(id, node_member_id)
          @id = id
          @node_member_id = node_member_id
          logger.debug("Member with id #{id} entered new state: #{self.class}")
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
            RSwim::Logger.new("Node #{@node_member_id}", STDERR)
          end
        end
      end
    end
  end
end
