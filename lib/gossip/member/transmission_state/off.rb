# frozen_string_literal: true

module Gossip
  module Member
    module TransmissionState
      class Off < Base
        def initialize(id)
          super(id, nil, nil, [], [])
        end

        def member_replied_with_ack
          logger.debug("out of order ack from member #{@id}")
        end

        def advance(_elapsed_seconds)
          self
        end
      end
    end
  end
end
