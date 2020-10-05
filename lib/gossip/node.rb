# frozen_string_literal: true

require 'socket'

module Gossip
  class Node
    def initialize(my_host, seed_hosts)
      @my_host = my_host
      @directory = Directory.new
      @my_id = @directory.id(@my_host)
      @deserializer = Integration::Deserializer.new(@directory, @my_id)
      @serializer = Integration::Serializer.new(@directory)
      @pipe = Gossip::Pipe.simple
      seed_ids = seed_hosts.map { |host| @directory.id(host) }
      @agent = Gossip::Agent::SleepBased.new(@pipe, @my_id, seed_ids)
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
        Gossip::Logger.new(self.class, STDERR)
      end
    end
  end
end
