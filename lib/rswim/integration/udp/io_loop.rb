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

      class IOLoop < RSwim::IOLoop
        def initialize(agent, serializer, deserializer, directory, sleep_time_seconds, my_host, port)
          super(agent, serializer, deserializer, directory, sleep_time_seconds)
          @my_host = my_host
          @port = port
        end

        protected

        def before_run
          @in_s = UDPSocket.new
          @in_s.bind(@my_host, @port)
          @out_q = Queue.new
          Thread.new { Sender.new(@port, @out_q).run }.abort_on_exception = true
        end

        def read
          text, sender = @in_s.recvfrom(10_000)
          [sender[3], text]
        rescue StandardError => e
          logger.debug("Error while receiving: #{e}")
        end

        def send(wire_messages)
          @out_q << wire_messages
        rescue StandardError => e
          logger.debug("Error while sending: #{e}")
        end
      end
    end
  end
end
