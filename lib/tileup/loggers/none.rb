module TileUp
  module Loggers
    class None < Logger

      class NullLogger < ::Logger
        def initialize(*args); end
        def add(*args, &block); end
      end

      private

      def create_logger
        NullLogger.new
      end

    end
  end
end
