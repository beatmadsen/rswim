# frozen_string_literal: true

module RSwim
  module Member
    module HealthState
      class Confirmed < Base
        def initialize(id, member_pool, update_entry)
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
      end
    end
  end
end
