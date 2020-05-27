# `Pretty::Crontab` represents `crontab(5)` information
#
# ### Usage
#
# ```crystal
# cron = Pretty::Crontab.parse("*/20 * * * * ls")
# cron.next_time # => "2019-04-18 08:00"
# cron.special?  # => nil
#
# cron = Pretty::Crontab.parse("@reboot rm -rf /tmp")
# cron.next_time # raises Pretty::Crontab::Error
# cron.special?  # => "reboot"
# ```

# m h  dom mon dow   command
class Pretty::Crontab
  class Error < Exception; end
  class ParseError < Error; end
  
  getter line         : String           # => "30 5-21/2 * * * ls /"
  getter mins         : Array(Int32)     # => [0, 30]
  getter hours        : Array(Int32)     # => [5,7,9,11,13,15,17,19,21]
  getter days         : Array(Int32)     # => [1,2,...31]
  getter months       : Array(Int32)     # => [1,2,...12]
  getter days_of_week : Array(Int32)     # => [0,1,...6]
  getter cmd          : String           # => "ls /"
  getter? special     : String?          # => "reboot"

  def self.special(name : String, line : String, cmd : String)
    empty = Array(Int32).new
    new(line, empty, empty, empty, empty, empty, cmd, name)
  end

  def initialize(@line, @mins, @hours, @days, @months, @days_of_week, @cmd, @special)
  end

  def to_s(io : IO)
    io << line
  end

  def inspect(io : IO)
    io.puts line
    if !special?
      io.puts "  mins         : %s" % mins.inspect
      io.puts "  hours        : %s" % hours.inspect
      io.puts "  days         : %s" % days.inspect
      io.puts "  months       : %s" % months.inspect
      io.puts "  days_of_week : %s" % days_of_week.inspect
      io.puts "  cmd          : %s" % cmd.inspect
    end
  end

  def next_time(from : ::Time = Pretty::Time.now) : ::Time
    if sp = special?
      raise Error.new("can't calculate time for special string [@#{sp}]")
    end

    time = from.dup.to_local

    raise Error.new("now supports only '*' for months") if months.size != 12
    raise Error.new("now supports only '*' for days")   if days.size   != 31

    today_candidates = create_candidates(time)

    if days_of_week.size == 7
      if found = today_candidates.find{|t| time <= t}
        return found
      else
        first = today_candidates.first? || raise "BUG: cron contains no data"
        return first + 1.day
      end
    else
      # When the day of the week is specified
      today = Pretty::Time.now(time.year, time.month, time.day)
      today_dow = time.day_of_week.value % 7
      target_dates = Array(::Time).new

      # Create a candidate date for this week and next
      days_of_week.each do |dow|
        target_date = today - (today_dow - dow).days
        target_dates << target_date
        target_dates << target_date + 7.days
      end
      target_dates = target_dates.sort

      if target_dates.includes?(today)
        today_next_time = today_candidates.find{|t| time <= t}
        return today_next_time if today_next_time
      end

      next_date = target_dates.find{|t| today < t} || raise ParseError.new("cron contains invalid data")
      next_candidates = create_candidates(next_date)
      next_time = next_candidates.find{|t| next_date <= t} || raise ParseError.new("cron contains invalid data")
      return next_time
    end
  end

  def create_candidates(time : ::Time) : Array(::Time)
    # corner-cutting implementation (make all candidates)
    candidates = Array(::Time).new
    hours.each do |h|
      mins.each do |m|
        candidates << ::Pretty.now(time.year, time.month, time.day, h, m)
      end
    end
    return candidates
  end

  def self.parse?(line : String) : Crontab?
    parse(line)
  rescue ArgumentError
    nil
  end

  def self.parse(line : String) : Crontab
    special = nil
    entry   = line

    # [CRONTAB(5) in ubuntu-20.04]
    # string         meaning
    # ------         -------
    # @reboot        Run once, at startup.
    # @yearly        Run once a year, "0 0 1 1 *".
    # @annually      (same as @yearly)
    # @monthly       Run once a month, "0 0 1 * *".
    # @weekly        Run once a week, "0 0 * * 0".
    # @daily         Run once a day, "0 0 * * *".
    # @midnight      (same as @daily)
    # @hourly        Run once an hour, "0 * * * *".
    case line
    when /^@(yearly|annually)\s*/
      line = "0 0 1 1 * #{$~.post_match}"
    when /^@monthly\s*/
      line = "0 0 1 * * #{$~.post_match}"
    when /^@weekly\s*/
      line = "0 0 * * 0 #{$~.post_match}"
    when /^@(daily|midnight)\s*/
      line = "0 0 * * * #{$~.post_match}"
    when /^@hourly\s*/
      line = "0 * * * * #{$~.post_match}"
    when /^@([a-z]+)\s*/
      # maybe "reboot" or future reserved words
      return self.special($1, line: line, cmd: $~.post_match.to_s)
    else
    end
      
    fields = line.split(/\s+/, 6)
    fields.size >= 5 || raise ParseError.new("crontab expects at least 5 fields, but got #{fields.size} (input: #{line.inspect})")
    
    m, h, dom, mon, dow = fields[0, 5]
    cmd = fields[5]?.to_s

    mins         = parse(m  , all: (0..59))
    hours        = parse(h  , all: (0..23))
    days         = parse(dom, all: (1..31))
    months       = parse(mon, all: (1..12))
    days_of_week = parse(dow, all: (0..6))

    return new(line, mins, hours, days, months, days_of_week, cmd, special)
  rescue err : ParseError
    raise ParseError.new("can't parse #{line.inspect}")
  end

  def self.parse(value : String, all : Range(Int32, Int32)) : Array(Int32)
    case value
    when "*"
      return all.to_a
    when /^\d+$/
      return [value.to_i]
    when /,/
      array = Array(Int32).new
      value.split(/,/).each do |v|
        array.concat parse(v, all: all)
      end
      return array.sort.uniq
    when /^\*\/(\d+)$/
      return all.to_a.select{|v| (v % $1.to_i) == 0}
    when /^(\d+)-(\d+)$/
      return ($1.to_i .. $2.to_i).to_a
    when /^(\d+)-(\d+)\/(\d+)$/
      return ($1.to_i .. $2.to_i).to_a.select{|v| (v % $3.to_i) == $1.to_i % $3.to_i}
    else
      raise ParseError.new("can't parse '#{value}'")
    end
  end
end
