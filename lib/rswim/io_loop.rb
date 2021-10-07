# frozen_string_literal: true

module RSwim
  class IOLoop
    def initialize(agent, serializer, deserializer, directory, sleep_time_seconds)
      @agent = agent
      @serializer = serializer
      @deserializer = deserializer
      @directory = directory
      @sleep_time_seconds = sleep_time_seconds
      @read_buffer = []
    end

    def run
      before_run
      Async do
        start_producer
        loop do
          in_messages = consume_read_buffer
          logger.debug "advancing agent with #{in_messages.size} messages"
          out_messages = @agent.advance(in_messages)
          wire_messages = out_messages.map do |message|
            wire_message = @serializer.serialize(message)
            host = @directory.host(message.to)
            [host, wire_message]
          end
          logger.debug "sending #{wire_messages.size} messages from agent to other hosts"
          send(wire_messages)
        rescue StandardError => e
          logger.debug("Error in I/O loop: #{e}")
        end
        logger.info 'node no longer receiving'
      end
    end

    protected

    def before_run; end

    def read
      raise 'implemented in subclass'
    end

    def send(_wire_messages)
      raise 'implemented in subclass'
    end

    def logger
      @_logger ||= RSwim::Logger.new(self.class, $stderr)
    end

    private

    def start_producer
      Fiber.schedule do
        loop do
          logger.debug 'about to recieve message'
          sender_host, wire_message = read
          continue if wire_message.nil?
          logger.debug "Read #{wire_message} from host #{sender_host}"
          message = @deserializer.deserialize(sender_host, wire_message)
          unless message.nil?
            logger.debug "Wire message deserialized to #{message}"
            @read_buffer << message
          end
        end
      end
    end

    def consume_read_buffer
      if @read_buffer.empty?
        logger.debug "sleeping for #{@sleep_time_seconds} seconds while waiting for buffered messages"
        sleep @sleep_time_seconds
      end
      Array.new(@read_buffer.size) { @read_buffer.pop }
    end
  end
end
