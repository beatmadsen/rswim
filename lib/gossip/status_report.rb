# frozen_string_literal: true

module Gossip
  class StatusReport
    def self.print(members)
      b = members.map { |k, m| "#{k}: #{m.health}\n" }.join
      a = <<~REPORT

        ====================================
         Status report:
        ====================================

        #{b}
        ====================================

      REPORT
      warn a
    end
  end
end
