require 'ostruct'
require 'logger'

module TileUp

  # Base logger class, subclass this, do not use directly.
  class Logger

    def self.build type, level, options = {}
      case type
      when 'none' then TileUp::Loggers::None.new(level, options)
      when ::Logger then TileUp::Logger.new(level, options.merge(logger: type))
      else TileUp::Loggers::Console.new(level, options)
      end
    end

    def self.sym_to_severity(sym)
      severities =  {
        :debug   => ::Logger::DEBUG,
        :info    => ::Logger::INFO,
        :warn    => ::Logger::WARN,
        :error   => ::Logger::ERROR,
        :fatal   => ::Logger::FATAL
      }
      severity = severities[sym] || ::Logger::UNKNOWN
    end

    # create logger set to given level
    # where level is a symbol (:debug, :info, :warn, :error, :fatal)
    # options may specifiy verbose, which will log more info messages
    def initialize(level, options = {})
      @severity = level
      @logger = options[:logger] if options[:logger]
      default_options = { verbose: false }
      @options = OpenStruct.new(default_options.merge(options))
    end

    def level
      @level
    end

    def level=(severity)
      logger.level = Logger.sym_to_severity(severity)
    end

    # log an error message
    def error(message)
      # note, we always log error messages
      add(:error, message)
    end

    # log a regular message
    def info(message)
      add(:info, message)
    end

    def warn(message)
      add(:warn, message)
    end

    # log a verbose message
    def verbose(message)
      add(:info, message) if verbose?
    end

    private

    # add message to log
    def add(severity, message)
      severity = Logger.sym_to_severity(severity)
      logger.add(severity, message)
    end

    # is logger in verbose mode?
    def verbose?
      @options.verbose
    end

    # create or return a logger
    def logger
      @logger ||= create_logger
    end

  private

    # subclasses should overwrite this method, creating what ever
    # logger they want to
    def create_logger
      raise "You should create your own `create_logger` method"
    end

  end

end
