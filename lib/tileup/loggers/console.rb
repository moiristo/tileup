module TileUp
  module Loggers
    class Console < Logger

      private

      def create_logger
        logger = ::Logger.new(STDOUT)
        logger.formatter = Proc.new do |sev, time, prg, msg|
          "#{time.strftime('%H:%M:%S').to_s} => #{msg}\n"
        end

        logger
      end

    end
  end
end
