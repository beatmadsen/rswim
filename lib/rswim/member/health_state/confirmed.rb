# frozen_string_literal: true

module RSwim
  module Member
    module HealthState
      class Confirmed < Base
        def initialize(id, node_member_id, member_pool, must_propagate: false)
          super
          @member_halted = false
          @member_removed = false
          @life_time_seconds = 0
        end

        def advance(elapsed_seconds)
          @life_time_seconds += elapsed_seconds
          unless @member_halted
            @member_pool.halt_member(@id)
            @member_halted = true
          end

          if !@member_removed && @life_time_seconds > 10
            @member_pool.remove_member(@id)
            @member_removed = true
          end

          self
        end

        def update_suspicion(_status, _old_incarnation_number, _gossip_incarnation_number)
          self
        end

        def status
          :confirmed
        end
      end
    end
  end
end
