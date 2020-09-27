# frozen_string_literal: true

module Gossip
  class StatusReport
    class << self

      def print(members)
        b = members.map { |k, m| "#{k}: #{m.prepare_update_entry.status}\n" }.join
        a = <<~REPORT

        ====================================
        Status report:
        ====================================

        #{b}
        ====================================

        REPORT
        logger.info(a)
      end

      private

      def logger
        @_logger ||= Logger.new(self, 'log/status.log', 10, 1024000)
      end
    end
  end
end
