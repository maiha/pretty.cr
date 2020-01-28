# Add new features to `Logger`
# - `formatter=(str : String)` 
# - `level=(str : String)`
#
# ```crystal
# logger.formatter = "{{mark}}, [{{time=%H:%M}}] {{prog=[%s] }}{{message}}"
# logger.info "foo", "main" # => "I, 23:57 [main] foo"
#
# logger.level = "INFO"
# logger.level # => Logger::Severity::INFO
# ```

require "logger"
require "colorize"

class Logger
  property colorize : Bool = false

  enum LevelOp
    LT
    LE
    EQ
    GT
    GE
    NE

    def self.parse(op : String)
      case op
      when "<" ; LT
      when "<="; LE
      when "=" ; EQ
      when ">" ; GT
      when ">="; GE
      when "<>"; NE
      when "!="; NE
      else
        raise ArgumentError.new("unknown level op: #{op.inspect}")
      end
    end
  end    

  property level_op : LevelOp = LevelOp::GE

  def self.new(io : IO?, level : String, formatter : Formatter | String = DEFAULT_FORMATTER, progname = "") : Logger
    logger = new(io, progname: progname)
    logger.level = level
    logger.formatter = formatter
    return logger
  end

  def formatter=(str : String)
    @formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
      msg = str.gsub(/\{\{([^=}]+)=?(.*?)\}\}/) {
        key = $1
        fmt = $2.empty? ? nil : $2
        begin
          v = case key
              when "mark"              ; severity.to_s[0]
              when "severity", "level" ; severity
              when "datetime", "time"  ; datetime
              when "progname", "prog"  ; progname
              when "message"           ; message
              when "pid"               ; Process.pid
              when "mem"               ; Pretty::MemInfo.process.max.to_s rescue "---"
              else                     ; "{{#{key}}}"
              end
          if v.is_a?(Time)
            fmt ? v.to_s(fmt) : v.to_s
          else
            if fmt && !v.to_s.empty?
              fmt % v
            else
              v.to_s
            end
          end
        rescue err
          "{{#{key}:#{err}}}"
        end
      }
      if colorize
        case severity
        when .error?, .fatal?
          msg = msg.colorize(:red)
        when .warn?
          msg = msg.colorize(:yellow)
        end
      end
      io << msg
    end
  end

  def level_op=(op : String)
    self.level_op = LevelOp.parse(op)
  end

  def level=(str : String)
    case str
    when /^([=<>]+)(.*)$/
      self.level_op = $1
      str = $2
    end
    self.level = Logger::Severity.parse(str)
  end

  # overwrites stdlib "src/logger.cr"
  def log(severity, message, progname = nil)
    if @io && level_match?(severity)
      write(severity, Time.local, progname || @progname, message)
    end
  end

  def log(severity, progname = nil)
    if @io && level_match?(severity)
      write(severity, Time.local, progname || @progname, yield)
    end
  end

  def level_match?(severity : Severity) : Bool
    case level_op
    when .lt? ; severity <  level
    when .le? ; severity <= level
    when .eq? ; severity == level
    when .gt? ; severity >  level
    when .ge? ; severity >= level
    when .ne? ; severity != level
    else
      raise NotImplementedError.new("#{level_op.inspect} is not supported yet")
    end    
  end
end
