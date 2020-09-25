# frozen_string_literal: true

class UpdateEntry
  attr_reader(:member_id, :status, :incarnation_number, :propagation_count)

  def initialize(member_id, status, incarnation_number, propagation_count)
    @member_id = member_id
    @status = status
    @incarnation_number = incarnation_number
    @propagation_count = propagation_count
  end
end
