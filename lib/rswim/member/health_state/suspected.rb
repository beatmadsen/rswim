# frozen_string_literal: true

module RSwim
  module Member
    module HealthState
      class Suspected < Base
        def initialize(id, node_member_id, member_pool, send_ping_request:, must_propagate: false)
          super(id, node_member_id, member_pool, must_propagate: must_propagate)
          @ping_request_sent = !send_ping_request
          @life_time_seconds = 0
        end

        def advance(elapsed_seconds)
          @life_time_seconds += elapsed_seconds
          unless @ping_request_sent
            @member_pool.send_ping_request_to_k_members(@id)
            @ping_request_sent = true
          end
          if @life_time_seconds > 60
            # TODO: make sure to propagate this information with priority
            Confirmed.new(@id, @node_member_id, @member_pool, must_propagate: true)
          else
            self
          end
        end

        def update_suspicion(status, old_incarnation_number, gossip_incarnation_number)
          case status
          when :confirmed then Confirmed.new(@id, @node_member_id, @member_pool)
          when :suspected then self
          when :alive
            if gossip_incarnation_number > old_incarnation_number
              Alive.new(@id, @node_member_id, @member_pool)
            else
              self
            end
          end
        end

        def can_be_pinged?
          true
        end

        def status
          :suspected
        end
      end
    end
  end
end
