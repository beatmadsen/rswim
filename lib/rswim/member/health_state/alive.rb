# frozen_string_literal: true

module RSwim
  module Member
    module HealthState
      class Alive < Base
        def initialize(id, member_pool, update_entry = UpdateEntry.new(id, :alive, 0, 0))
          super
          @failed_to_reply = false
        end

        def advance(_elapsed_seconds)
          if @failed_to_reply
            ue = UpdateEntry.new(@id, :suspected, @update_entry.incarnation_number, -1)
            Suspected.new(@id, @member_pool, ue, true)
          else
            self
          end
        end

        def member_failed_to_reply
          @failed_to_reply = true
        end

        def can_be_pinged?
          true
        end
      end
    end
  end
end
