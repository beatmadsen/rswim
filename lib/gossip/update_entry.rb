# frozen_string_literal: true

class UpdateEntry
  attr_reader(:member_id, :status, :incarnation_number)

  def initialize(member_id, status, incarnation_number)
    @member_id = member_id
    @status = status
    @incarnation_number = incarnation_number
  end
end
