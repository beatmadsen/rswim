# frozen_string_literal: true
module Gossip
  class UpdateEntry
    attr_reader :member_id, :status, :incarnation_number, :propagation_count

    def initialize(member_id, status, incarnation_number, propagation_count = 0)
      @member_id = member_id
      @status = status
      @incarnation_number = incarnation_number
      @propagation_count = propagation_count
    end

    def increment_propagation_count
      @propagation_count += 1
    end
  end
end
