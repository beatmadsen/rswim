# frozen_string_literal: true

module RSwim
  module Member
    module HealthState
      class Base
        attr_reader :propagation_count

        def initialize(id, node_member_id, member_pool, must_propagate:)
          @member_pool = member_pool
          @id = id
          @node_member_id = node_member_id
          @propagation_count = must_propagate ? -2 : 0
          logger.debug("Member with id #{id} entered new state: #{self.class}")
        end

        def increment_propagation_count
          @propagation_count += 1
        end

        def advance(_elapsed_seconds)
          self
        end

        def member_failed_to_reply; end

        def can_be_pinged?
          false
        end

        protected

        def logger
          @_logger ||= RSwim::Logger.new("Node #{@node_member_id}", STDERR)
        end
      end
    end
  end
end
