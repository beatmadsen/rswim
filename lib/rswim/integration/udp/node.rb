# frozen_string_literal: true

require 'socket'

module RSwim
  module Integration
    module Udp
      # Node implementation that sends and listens using UDP
      class Node < RSwim::Node
        def initialize(my_host, seed_hosts, port, t_ms, r_ms)
          my_host ||= Socket.ip_address_list.find(&:ipv4_private?).ip_address
          super(my_host, seed_hosts, t_ms, r_ms)
          @port = port
        end

        protected

        def before_start
          @in_s = UDPSocket.new
          @out_s = UDPSocket.new
          @in_s.bind(@my_host, @port)
          logger.info "node listening on UDP port #{@port}"
          Thread.new { receive }.abort_on_exception = true
          Thread.new { send }.abort_on_exception = true
        end

        private

        def send
          loop do
            message = @pipe.q_out.pop
            wire_message = @serializer.serialize(message)
            host = @directory.host(message.to)
            logger.debug "about to send message to #{host}"
            @out_s.send(wire_message, 0, host, @port)
          rescue StandardError => e
            logger.debug("Error while sending: #{e}")
          end
          logger.info 'node no longer receiving'
        end

        def receive
          loop do
            logger.debug 'about to recieve message'
            text, sender = @in_s.recvfrom(10_000)

            message = @deserializer.deserialize(sender[3], text)
            logger.debug "received #{message}"
            @pipe.q_in << message
          rescue StandardError => e
            logger.debug("Error while receiving: #{e}")
          end
          logger.info 'node no longer receiving'
        end
      end
    end
  end
end
