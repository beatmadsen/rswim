# frozen_string_literal: true

module Gossip
  module Member
    module State
      class Base
        attr_reader :update_entry

        def initialize(id, node_member_id, member_pool, update_entry)
          logger.debug("Member with id #{id} entered new state")
          @member_pool = member_pool
          @id = id
          @node_member_id = node_member_id
          @update_entry = update_entry
        end

        def member_replied_with_ack; end

        def advance(_elapsed_seconds)
          self
        end

        def prepare_output
          []
        end

        def transition_on_ping
          raise 'called at unexpected time'
        end

        def transition_on_ping_request(target_id)
          raise 'called at unexpected time'
        end

        def transition_on_forward_ping(source_id)
          raise 'called at unexpected time'
        end

        def increment_propagation_count
          @update_entry.increment_propagation_count
        end

        def can_be_pinged?
          false
        end

        private

        def logger
          @_logger ||= begin
            Gossip::Logger.new(self.class, STDERR)
          end
        end
      end
    end
  end
end