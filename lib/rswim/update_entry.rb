# frozen_string_literal: true

module RSwim
  class UpdateEntry
    attr_reader :member_id, :status, :incarnation_number, :propagation_count, :custom_state

    def initialize(member_id, status, incarnation_number, custom_state, propagation_count = 0)
      @member_id = member_id
      @status = status
      @incarnation_number = incarnation_number
      @custom_state = custom_state
      @propagation_count = propagation_count
    end

    def ==(other)
      %i[member_id status incarnation_number propagation_count custom_state].all? do |a|
        send(a) == other.send(a)
      end
    end
  end
end
