module Builder::Helpers
  module Logger
    def logger
      Builder.logger
    end

    def info(msg)
      logger.info msg
    end

    def error(msg)
      logger.error msg
    end

    def debug(msg)
      logger.debug msg
    end

    def warn(msg)
      logger.warn msg
    end
  end
end
