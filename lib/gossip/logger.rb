module Gossip
  class Logger < ::Logger
    def initialize(klass, *args, **options)
      options[:formatter] = LeFormatter.new(klass)
      super(*args, **options)
    end

    class LeFormatter < ::Logger::Formatter
      def initialize(klass)
        super()
        @klass = klass
      end

      def call(severity, timestamp, progname, msg)
        m = String === msg ? msg : msg.inspect
        "#{timestamp} | #{severity} | #{@klass} | #{m}\n"
      end
    end
  end
end
