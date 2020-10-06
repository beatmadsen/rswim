# frozen_string_literal: true

module RSwim
  module Member
    module TransmissionState
      class Base
        def initialize(id, node_member_id, member_pool, source_ids, target_ids)
          @member_pool = member_pool
          @id = id
          @node_member_id = node_member_id
          @source_ids = source_ids
          @target_ids = target_ids
          logger.debug("Member with id #{id} entered new state: #{self.class}")
        end

        def member_replied_with_ack; end

        def advance(_elapsed_seconds)
          self
        end

        def prepare_output
          []
        end

        def enqueue_ping
          @source_ids << @id
        end

        def enqueue_ping_from(source_id)
          @source_ids << source_id
        end

        def enqueue_ping_request(target_id)
          @target_ids << target_id
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
