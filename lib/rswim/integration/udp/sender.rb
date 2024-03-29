# frozen_string_literal: true

module RSwim
  module Integration
    module UDP
      class Sender
        def initialize(port, out_q)
          @out_q = out_q
          @port = port
          @out_s = UDPSocket.new
        end

        def run
          Async do
            loop do
              wire_messages = @out_q.pop
              wire_messages.each do |(host, wire_message)|
                logger.debug "about to send message to #{host} on port #{@port}"
                Fiber.schedule do
                  @out_s.send(wire_message, 0, host, @port)
                rescue StandardError => e
                  logger.debug("Error while sending: #{e}")
                end
              end
            end
          end
        end

        private

        def logger
          @_logger ||= RSwim::Logger.new(self.class, $stderr)
        end
      end
    end
  end
end
