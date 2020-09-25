# frozen_string_literal: true

module Gossip
  module Member
    module State
      class Alive < Base
        def initialize(id, member_pool)
          super
        end

        def health
          'alive'
        end
      end
    end
  end
end
