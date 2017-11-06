class Log
  RED_COLOR = "\033[01;31m"
  RESET_COLOR = "\033[00m"
  GREEN_COLOR = "\033[32m"
  BLUE_COLOR = "\033[34m"
  PURPLE_COLOUR = "\033[01;35m"
  class << self
    def info(*messages)
      messages.each { |message| puts "#{GREEN_COLOR}[Info] #{message}#{RESET_COLOR}" }
    end

    def warn(*messages)
      messages.each { |message| puts "#{BLUE_COLOR}[Warning] #{message} #{RESET_COLOR}" }
    end

    def error(*messages)
      messages.each { |message| puts "#{RED_COLOR}[Error!] #{message}#{RESET_COLOR}" }
      exit 1
    end
    def error(*messages)
      messages.each { |message| puts "#{RED_COLOR}[Error!] #{message}#{RESET_COLOR}" }
      exit 1
    end
    def error_and_continue(*messages)
      messages.each { |message| puts "#{PURPLE_COLOUR}[Error!] #{message}#{RESET_COLOR}" }
    end
  end
end
