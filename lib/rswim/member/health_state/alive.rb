# frozen_string_literal: true

module RSwim
  module Member
    module HealthState
      class Alive < Base
        def initialize(id, node_member_id, member_pool, must_propagate: false)
          super
          @failed_to_reply = false
        end

        def advance(_elapsed_seconds)
          if @failed_to_reply
            Suspected.new(@id, @node_member_id, @member_pool, must_propagate: true, send_ping_request: true)
          else
            self
          end
        end

        def update_suspicion(status, old_incarnation_number, gossip_incarnation_number)
          case status
          when :confirmed then Confirmed.new(@id, @node_member_id, @member_pool)
          when :suspected
            if gossip_incarnation_number >= old_incarnation_number
              Suspected.new(@id, @node_member_id, @member_pool, send_ping_request: false)
            else
              self
            end
          when :alive then self
          end
        end

        def member_failed_to_reply
          @failed_to_reply = true
        end

        def can_be_pinged?
          true
        end

        def status
          :alive
        end
      end
    end
  end
end
