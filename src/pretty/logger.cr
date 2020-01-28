class Pretty::Logger < ::Logger
  include Enumerable(::Logger)

  DEFAULT_FORMATTER = "{{mark}},[{{time=%H:%M:%S}}]({{mem}}) {{message}}"
  
  property loggers : Array(::Logger)
  @memory : IO::Memory?
  
  def initialize(loggers : Array(::Logger)? = nil, memory : Logger::Severity | String | Nil = nil, formatter = DEFAULT_FORMATTER)
    @loggers = loggers || Array(::Logger).new
    if memory
      @memory = IO::Memory.new
      @loggers << ::Logger.new(@memory).tap(&.level = memory)
    end
    super(nil)
    self.formatter = formatter
  end

  def memory? : IO::Memory?
    memory
  rescue
    nil
  end

  def memory : IO::Memory
    @memory || raise "Memory logger is not enabled"
  end

  delegate each, to: @loggers

  def <<(logger : ::Logger)
    @loggers << logger
  end
  
  def <<(hash : Hash)
    self << self.class.build_logger(hash)
  end
  
  {% for method in %w( colorize= formatter= level= level_op= ) %}
    def {{method.id}}(v)
      each do |logger|
        logger.{{method.id}}(v)
      end
    end
  {% end %}

  {% for method in %w( close ) %}
    def {{method.id}}(*args)
      each do |logger|
        logger.{{method.id}}(*args)
      end
    end
  {% end %}

  {% for method in %w( debug info warn error fatal log ) %}
    def {{method.id}}(*args, **options)
      each do |logger|
        logger.{{method.id}}(*args, **options)
      end
    end

    def {{method.id}}(*args, **options)
      each do |logger|
        logger.{{method.id}}(*args, **options) do |*yield_args|
          yield *yield_args
        end
      end
    end
  {% end %}
end

class Pretty::Logger
  def self.build_logger(hash : Hash)
    mode = hash["mode"]?.try(&.to_s) || "w+"
    path = hash["path"]?.try(&.to_s) || "STDOUT"
    io = {"STDOUT" => STDOUT, "STDERR" => STDERR}[path]? || ::File.open(path, mode)
    logger = ::Logger.new(io)
    logger.level     = hash["level"].to_s if hash["level"]?
    logger.formatter = (hash["format"]? || DEFAULT_FORMATTER).to_s
    logger.colorize  = true if hash["colorize"]?
    logger
  end

  def self.new(io : IO?, **args) : Pretty::Logger
    new(::Logger.new(io, **args))
  end

  def self.new(logger : Pretty::Logger, **args) : Pretty::Logger
    Pretty::Logger.new(logger.loggers, **args)
  end

  def self.new(logger : ::Logger, **args) : Pretty::Logger
    Pretty::Logger.new([logger], **args)
  end

  def self.new(loggers : Array(Hash(String, String)), **args) : Pretty::Logger
    loggers = loggers.map{|hash| build_logger(hash)}
    Pretty::Logger.new(loggers, **args)
  end
end
