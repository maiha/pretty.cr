class Pretty::Version
  # `Pretty::Version` holds version information as `Array(Int32)`.
  # - handy accessors: `major`, `minor`, `rev`
  # - sorting feature
  #
  # ```crystal
  # Pretty::Version.parse("0.27.2")[1,2]  # => [27,2]
  # Pretty::Version.parse("0.27.2").minor # => 27
  #
  # Pretty.version("0.27.2") # shortcut for `Pretty::Version.parse`
  # ```
  property values : Array(Int32)
  property build  : String = ""
  property sep    : String = ""

  include Enumerable(Int32)

  delegate :size, :each, :last, :[], :[]?, to: @values
  
  def initialize(values : Array(Int32)? = nil, build = nil, sep = nil)
    @values = values || Array(Int32).new
    @build  = build  || ""
    @sep    = sep    || ""
  end

  # handy accessors
  def major ; self[0] ; end
  def major?; self[0]?; end
  def minor ; self[1] ; end
  def minor?; self[1]?; end
  def rev   ; self[2] ; end
  def rev?  ; self[2]?; end

  # sorting feature
  {% for m in %w( < <= ) %}
    def {{m.id}}(other : Version)
      values {{m.id}} other.values
    end
  {% end %}

  def <=>(other : Version)
    values <=> other.values
  end
  
  def to_s(io : IO)
    io << values.map(&.to_s).join(".")
    io << sep.to_s
    io << build.to_s
  end

  def self.parse(string : String) : Version
    case string                           # "0.27.2-dev"
    when /\A(\d+(\.\d+)*)([^a-z\d]*)(.*)\Z/
      values  = $1.split(".").map(&.to_i) # => [0, 27, 2]
      sep     = $3                        # "-"
      build   = $4                        # "dev"
      return new(values, sep: sep, build: build)
    else
      raise ArgumentError.new("cannot parse version string: #{string.inspect}")
    end        
  end
end

def Pretty.version(s : String)
  Pretty::Version.parse(s)
end
