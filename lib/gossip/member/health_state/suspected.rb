# frozen_string_literal: true

module Gossip
  module Member
    module HealthState
      class Suspected < Base
        def initialize(id, member_pool, update_entry, send_ping_request)
          super(id, member_pool, update_entry)
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
            Confirmed.new(@id, @member_pool, UpdateEntry.new(@id, :confirmed, @update_entry.incarnation_number, 0))
          else
            self
          end
        end

        def can_be_pinged?
          true
        end
      end
    end
  end
end
