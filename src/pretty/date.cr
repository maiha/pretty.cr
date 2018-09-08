# `Pretty::Date.parse` is a handy parser for date strings.
#
# ### Usage
#
# ```crystal
# Pretty::Date.parse("2001-02-03")
# Pretty::Date.parse("2001/02/03")
# Pretty::Date.parse("20010203")
# Pretty::Date.parse("yesterday")
# Pretty::Date.parse("1 day ago")
# Pretty::Date.parse?("foo")
# ```
module Pretty::Date
  class ParseError < Exception
    property value : String

    def initialize(@value : String)
      super("can't parse time: '%s'" % @value)
    end
  end

  def self.parse?(value : String) : ::Time?
    parse(value) rescue nil
  end

  def self.parse(value : String) : ::Time
    case value.delete("/-")
    when /^(\d{4})(\d{2})(\d{2})$/
      return ::Time.new($1.to_i, $2.to_i, $3.to_i)
    when /^(\d{4})(\d{2})$/
      return ::Time.new($1.to_i, $2.to_i, 1)
    when /^\+?(\d+)\s+days?(\s+hence)?$/
      return $1.to_i.day.from_now.at_beginning_of_day
    when /^\+?(\d+)\s+days?\s+ago$/
      return $1.to_i.day.ago.at_beginning_of_day
    when /^now$/
      return ::Time.now.at_beginning_of_day
    when /^yesterday$/
      return 1.day.ago.at_beginning_of_day
    when /^tomorrow$/
      return 1.day.from_now.at_beginning_of_day
    else
      raise ParseError.new(value)
    end
  end

  def self.parse_dates?(value) : Array(::Time)?
    parse_dates(value) rescue nil
  end

  def self.parse_dates(value : String) : Array(::Time)
    case value
    when /^(\d{6})-(\d{6})$/
      d1 = parse($1)
      d2 = parse($2)
      # adjust the end of month for d2
      d2 = d2.at_end_of_month.at_beginning_of_day
    when /^(\d{8})-(\d{8})$/, /^([^-]+)-([^-]+)$/
      d1 = parse($1)
      d2 = parse($2)
    when /^(\d{6})$/
      d1 = parse($1)
      d2 = d1.at_end_of_month.at_beginning_of_day
    else
      d1 = d2 = parse(value)
    end

    if d1 && d2
      dates = Array(::Time).new
      d = d1
      while d <= d2
        dates << d
        d = d + 1.day
      end
      return dates
    else
      raise ParseError.new(value)
    end
  end
end

# `Pretty.date` is a alias for `Pretty::Date.parse`.
# `Pretty.dates` is a alias for `Pretty::Date.parse_dates`.
#
# ### Usage
#
# ```crystal
# Pretty.date("2001-02-03")
# Pretty.dates("20180908-20180909")
# Pretty.dates("201809")
# ```
module Pretty
  def self.date(value : String) : ::Time
    Pretty::Date.parse(value)
  end

  def self.date?(value : String) : ::Time?
    Pretty::Date.parse?(value)
  end

  def self.dates(value : String) : Array(::Time)
    Pretty::Date.parse_dates(value)
  end

  def self.dates?(value : String) : Array(::Time)?
    Pretty::Date.parse_dates?(value)
  end
end
