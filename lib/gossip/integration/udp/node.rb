# frozen_string_literal: true

require 'socket'

module Gossip
  module Integration
    module Udp
      class Node < Gossip::Node
        def initialize(my_host, seed_hosts, port)
          super(my_host, seed_hosts)
          @port = port
        end

        protected

        def before_start
          @s = UDPSocket.new
          @s.bind(nil, @port)
          logger.info "node listening on UDP port #{@port}"
          Thread.new { receive }.tap { |t| t.abort_on_exception = true }
          Thread.new { send }.tap { |t| t.abort_on_exception = true }
        end

        private

        def send
          loop do
            begin
              message = @pipe.q_out.pop
              wire_message = @serializer.serialize(message)
              host = @directory.host(message.to)
              logger.debug "about to send message to #{host}"
              @s.send(wire_message, 0, host, @port)
            rescue StandardError => e
              logger.debug("Error while sending: #{e}")
            end
          end
          logger.info 'node no longer receiving'
        end

        def receive
          loop do
            begin
              logger.debug 'about to recieve message'
              text, sender = @s.recvfrom(10_000)

              message = @deserializer.deserialize(sender[3], text)
              logger.debug "received #{message}"
              @pipe.q_in << message
            rescue StandardError => e
              logger.debug("Error while receiving: #{e}")
            end
          end
          logger.info 'node no longer receiving'
        end
      end
    end
  end
end
