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
    kind ||= ::Time::Kind::Utc
    pattern = guess_pattern(value)
    ::Time.parse(value, pattern, kind)
  end

  private def self.guess_pattern(value : String)
    case value
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}\Z/
      # "2000-01-02 03:04:05"
      # "2000-01-02T03:04:05"
      "%F#{$1}%T"
    when /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}( ?)\+\d{2}(:?)\d{2}\Z/
      # "2000-01-02T03:04:05+0900"
      # "2000-01-02T03:04:05+09:00"
      # "2000-01-02T03:04:05 +0900"
      # "2000-01-02T03:04:05 +09:00"
      "%FT%T#{$1}%#{$2}z"
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}\.\d{3}\Z/
      # "2000-01-02 03:04:05.678"
      # "2000-01-02T03:04:05.678"
      "%F#{$1}%T.%L"
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}\.\d{3}( ?)\+\d{2}(:?)\d{2}\Z/
      # "2000-01-02 03:04:05.678+0900"
      # "2000-01-02 03:04:05.678+09:00"
      # "2000-01-02T03:04:05.678 +0900"
      # "2000-01-02T03:04:05.678 +09:00"
      "%F#{$1}%T.%L#{$2}%#{$3}z"
    when /\A(\d{4}-\d{2}-\d{2})\Z/
      # "2000-01-02"
      "%F"
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
