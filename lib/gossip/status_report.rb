# frozen_string_literal: true

module Gossip
  class StatusReport
    class << self

      def print(members)
        b = members.map { |k, m| "#{k}: #{m.health}\n" }.join
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
        @_logger ||= Logger.new('log/status.log', 10, 1024000)
      end
    end
  end
end
