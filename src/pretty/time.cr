# `Pretty::Time.parse` is a handy replacement of `Time.parse`.
#
# ### Usage
#
# ```crystal
# Pretty::Time.parse("2000-01-02 03:04:05")
# Pretty::Time.parse("2000-01-02 03:04:05.678")
# Pretty::Time.parse("2000-01-02T03:04:05+0900")
# Pretty::Time.parse("2000-01-02T03:04:05.678+09:00")
# ```
module Pretty::Time
  class ParseError < Exception
    property value : String

    def initialize(@value : String)
      super("can't parse time: '%s'" % @value)
    end
  end

  def self.parse(value : String, kind : ::Time::Kind? = nil) : ::Time
    utc = ::Time::Kind::Utc
    kind ||= utc
    case value
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}(Z?)\Z/
      # "2000-01-02 03:04:05"
      # "2000-01-02T03:04:05"
      # "2000-01-02T03:04:05Z"
      kind = utc if $2
      ::Time.parse(value, "%F#{$1}%T", kind)
    when /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}( ?)\+\d{2}(:?)\d{2}\Z/
      # "2000-01-02T03:04:05+0900"
      # "2000-01-02T03:04:05+09:00"
      # "2000-01-02T03:04:05 +0900"
      # "2000-01-02T03:04:05 +09:00"
      ::Time.parse(value, "%FT%T#{$1}%#{$2}z", kind)
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}\.\d{3}(Z?)\Z/
      # "2000-01-02 03:04:05.678"
      # "2000-01-02T03:04:05.678"
      # "2000-01-02T03:04:05.678Z"
      kind = utc if $2
      ::Time.parse(value, "%F#{$1}%T.%L", kind)
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}\.\d{3}( ?)\+\d{2}(:?)\d{2}\Z/
      # "2000-01-02 03:04:05.678+0900"
      # "2000-01-02 03:04:05.678+09:00"
      # "2000-01-02T03:04:05.678 +0900"
      # "2000-01-02T03:04:05.678 +09:00"
      ::Time.parse(value, "%F#{$1}%T.%L#{$2}%#{$3}z", kind)
    when /\A(\d{4}-\d{2}-\d{2})\Z/
      # "2000-01-02"
      ::Time.parse(value, "%F", kind)
    else
      raise ParseError.new(value)
    end
  end
end

# `Pretty.time` is a alias for `Pretty::Time.parse`.
#
# ### Usage
#
# ```crystal
# Pretty.parse("2006-01-02 15:04:05")
# ```
module Pretty
  def self.time(value : String, kind : ::Time::Kind? = nil) : ::Time
    Pretty::Time.parse(value, kind: kind)
  end
end
