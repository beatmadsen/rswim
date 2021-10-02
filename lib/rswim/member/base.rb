# frozen_string_literal: true

module RSwim
  module Member
    class Base
      def initialize(id)
        @id = id
        @incarnation_number = 0        
      end
    end
  end
end
