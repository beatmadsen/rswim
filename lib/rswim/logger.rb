module RSwim
  class Logger < ::Logger
    def initialize(klass, *args, **options)
      options[:formatter] = LeFormatter.new(klass)
      super(*args, **options)
      self.level=Logger.level
    end

    class << self
      def level=(severity)
        @level = severity
      end

      def level
        @level ||= ::Logger::INFO
      end
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
