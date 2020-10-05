# frozen_string_literal: true

require 'socket'

module Gossip
  class Node
    def initialize(my_host)
      @my_host = my_host
      @directory = Directory.new
      @my_id = @directory.id(@my_host)
      @deserializer = Integration::Deserializer.new(@directory, @my_id)
      @serializer = Integration::Serializer.new(@directory)
    end

    protected

    def logger
      @_logger ||= begin
        Gossip::Logger.new(self.class, STDERR)
      end
    end
  end
end
