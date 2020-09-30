# frozen_string_literal: true

module Gossip
  class StatusReport
    class << self

      def print(node_member_id, members)
        b = members.map { |k, m| "#{k}: #{m.prepare_update_entry.status}\n" }.join
        a = <<~REPORT

        ==========================================
        Status report for node #{node_member_id}:
        ==========================================

        #{b}
        ==========================================

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
