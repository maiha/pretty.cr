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

  def self.parse?(value : String, location : ::Time::Location? = nil) : ::Time?
    parse(value, location) rescue nil
  end
  
  def self.parse(value : String, location : ::Time::Location? = nil) : ::Time
    utc = ::Time::Location::UTC
    location ||= utc
    case value
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}( ?)[+-]\d{2}(:?)\d{2}/
      # "2000-01-02T03:04:05+0900"
      # "2000-01-02T03:04:05+09:00"
      # "2000-01-02T03:04:05 +0900"
      # "2000-01-02 03:04:05 +0900"
      # "2000-01-02T03:04:05 +09:00"
      # "2000-01-02 03:04:05 +0900 Japan"
      # "2000-01-02 03:04:05 -03:00 America/Buenos_Aires"
      ::Time.parse(value, "%F#{$1}%T#{$2}%#{$3}z", location)
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}\.\d{1,3}( ?)\+\d{2}(:?)\d{2}/
      # "2000-01-02 03:04:05.678+0900"
      # "2000-01-02 03:04:05.678+09:00"
      # "2000-01-02T03:04:05.678 +0900"
      # "2000-01-02T03:04:05.678 +09:00"
      # "2000-01-02 03:04:05.0 +09:00 Asia/Tokyo"
      ::Time.parse(value, "%F#{$1}%T.%L#{$2}%#{$3}z", location)
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}\.\d{3}(Z?)/
      # "2000-01-02 03:04:05.678"
      # "2000-01-02T03:04:05.678"
      # "2000-01-02T03:04:05.678Z"
      # "2000-01-02 03:04:05.000 UTC"
      location = utc if $2.to_s != ""
      ::Time.parse(value, "%F#{$1}%T.%L", location)
    when /\A\d{4}-\d{2}-\d{2}([ T])\d{2}:\d{2}:\d{2}(Z?)/
      # "2000-01-02 03:04:05"
      # "2000-01-02T03:04:05"
      # "2000-01-02T03:04:05Z"
      # "2000-01-02 03:04:05 UTC"
      location = utc if $2.to_s != ""
      ::Time.parse(value, "%F#{$1}%T", location)
    when /\A(\d{4}-\d{2}-\d{2})\Z/
      # "2000-01-02"
      ::Time.parse(value, "%F", location)
    when /\A(?<year>\d{4})[-: \/]?(?<month>\d{2})[-: \/]?(?<day>\d{2})[-: ]?(?<hour>\d{2})[-: ]?(?<min>\d{2})[-: ]?(?<sec>\d{2})?\Z/
      # finally, we give best effort to parse something
      parse($~["year"].to_i, $~["month"].to_i, $~["day"].to_i, $~["hour"].to_i, $~["min"].to_i,  $~["sec"]?.try(&.to_i) || 0, location: location)
    else
      raise ParseError.new(value)
    end
  end

  # for backward compatibility
  def self.now(*args, **options) : ::Time
    {% if ::Crystal::VERSION =~ /^0\.(1\d|2[0-7])\./ %}
      ::Time.new(*args, **options)
    {% else %}
      ::Time.local(*args, **options)
    {% end %}
  end

  {% if ::Crystal::VERSION =~ /^0\.(1\d|2[0-7])\./ %}
    def self.utc(year : Int32 = Time.now.year, month : Int32 = Time.now.month, day : Int32 = Time.now.day, hour : Int32 = 0, minute : Int32 = 0, second : Int32 = 0, *, nanosecond : Int32 = 0) : ::Time
      ::Time.new(year, month, day, hour, minute, second, nanosecond: nanosecond, location: ::Time::Location::UTC)
    end
  {% else %}
    def self.utc(*args, **options) : ::Time
      ::Time.utc(*args, **options)
    end
  {% end %}

  def self.parse(year : Int32, month : Int32, day : Int32, hour : Int32 = 0, minute : Int32 = 0, second : Int32 = 0, *args, **opts)
    {% if ::Crystal::VERSION =~ /^0\.(1\d|2[0-7])\./ %}
      ::Time.new(year, month, day, hour, minute, second, *args, **opts)
    {% else %}
      ::Time.local(year, month, day, hour, minute, second, *args, **opts)
    {% end %}
  end
end

# `Pretty.time` is a alias for `Pretty::Time.parse`.
#
# ### Usage
#
# ```crystal
# Pretty.time("2006-01-02 15:04:05")
# ```
module Pretty
  def self.now(*args, **options) : ::Time
    Pretty::Time.now(*args, **options)
  end

  def self.utc(*args, **options) : ::Time
    Pretty::Time.utc(*args, **options)
  end

  def self.time(value : String, location : ::Time::Location? = nil) : ::Time
    Pretty::Time.parse(value, location: location)
  end

  def self.time?(value : String, location : ::Time::Location? = nil) : ::Time?
    Pretty::Time.parse?(value, location: location)
  end

  def self.epoch(seconds : Int) : ::Time
    {% if ::Crystal::VERSION =~ /^0\.(1\d|2[0-3])\./ %}
      ::Time.epoch(seconds)
    {% else %}
      ::Time.unix(seconds)
    {% end %}
  end

  def self.epoch_ms(milliseconds : Int) : ::Time
    {% if ::Crystal::VERSION =~ /^0\.(1\d|2[0-3])\./ %}
      ::Time.epoch_ms(milliseconds)
    {% else %}
      ::Time.unix_ms(milliseconds)
    {% end %}
  end
end
