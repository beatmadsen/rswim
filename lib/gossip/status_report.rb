module Gossip
  class StatusReport
    def self.print(members)
      a = <<~REPORT

        ====================================
         Status report:
        ====================================

      REPORT
      b = members.map { |k, m| "#{k}: #{m.health}\n" }.join
      puts a + b
    end
  end
end
