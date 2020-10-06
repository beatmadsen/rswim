# frozen_string_literal: true

require 'socket'

module RSwim
  class Node
    def initialize(my_host, seed_hosts)
      @my_host = my_host
      @directory = Directory.new
      @my_id = @directory.id(@my_host)
      @deserializer = Integration::Deserializer.new(@directory, @my_id)
      @serializer = Integration::Serializer.new(@directory)
      @pipe = RSwim::Pipe.simple
      seed_ids = seed_hosts.map { |host| @directory.id(host) }
      @agent = RSwim::Agent::SleepBased.new(@pipe, @my_id, seed_ids)
    end

    def self.udp(my_host, seed_hosts, port)
      Integration::Udp::Node.new(my_host, seed_hosts, port)
    end

    def subscribe(&block)
      @agent.subscribe do |id, status|
        host = @directory.host(id)
        block.call(host, status)
      end
    end

    # blocks until interrupted
    def start
      logger.info 'starting node'
      before_start
      @agent.run
    rescue StandardError => e
      logger.debug("Error: #{e}")
    end

    protected

    def before_start
      raise 'must be implemented in subclass'
    end

    def logger
      @_logger ||= begin
        RSwim::Logger.new(self.class, STDERR)
      end
    end
  end
end
