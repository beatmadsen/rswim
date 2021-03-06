# frozen_string_literal: true

module RSwim
  module Member
    module HealthState
      class Base
        attr_reader :update_entry

        def initialize(id, member_pool, update_entry)
          @member_pool = member_pool
          @id = id
          @update_entry = update_entry
          logger.debug("Member with id #{id} entered new state: #{self.class}")
        end

        def advance(_elapsed_seconds)
          self
        end

        def update_suspicion(status, incarnation_number)
          incarnation_number ||= @update_entry.incarnation_number
          s0 = @update_entry.status
          i0 = @update_entry.incarnation_number
          case status
          when :confirmed
            if (s0 == :confirmed)
              self
            else
              ue = UpdateEntry.new(@id, status, incarnation_number, 0)
              Confirmed.new(@id, @member_pool, ue)
            end
          when :suspected
            if (s0 == :suspected && incarnation_number > i0) ||
               (s0 == :alive && incarnation_number >= i0)
              ue = UpdateEntry.new(@id, status, incarnation_number, 0)
              Suspected.new(@id, @member_pool, ue, false)
            else
              self
            end
          when :alive
            if (s0 == :suspected && incarnation_number > i0) ||
               (s0 == :alive && incarnation_number > i0)
              ue = UpdateEntry.new(@id, status, incarnation_number, 0)
              Alive.new(@id, @member_pool, ue)
            else
              self
            end
          end
        end

        def member_failed_to_reply; end

        def increment_propagation_count
          @update_entry.increment_propagation_count
        end

        def can_be_pinged?
          false
        end

        protected

        def logger
          @_logger ||= begin
            RSwim::Logger.new("unknown node", STDERR)
          end
        end
      end
    end
  end
end
