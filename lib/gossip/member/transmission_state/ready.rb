# frozen_string_literal: true

module Gossip
  module Member
    module TransmissionState
      class Ready < Base
        def initialize(id, node_member_id, member_pool, source_ids = [], target_ids = [])
          super
        end

        def member_replied_with_ack
          log.debug("out of order ack from member #{@id}")
        end

        def advance(_elapsed_seconds)
          if !@source_ids.empty?
            SendingPing.new(@id, @node_member_id, @member_pool, @source_ids, @target_ids)
          elsif !@target_ids.empty?
            SendingPingRequest.new(@id, @node_member_id, @member_pool, @source_ids, @target_ids)
          else
            self
          end
        end
      end
    end
  end
end
