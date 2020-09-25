# frozen_string_literal: true

module Gossip
  module Member
    module State
      class Base
        def initialize(id, member_pool)
          logger.debug("Member with id #{id} entered new state")
          @member_pool = member_pool
          @id = id
        end

        def member_replied_with_ack; end

        def advance(_elapsed_seconds)
          self
        end

        def prepare_output
          []
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
