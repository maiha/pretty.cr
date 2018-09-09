class Pretty::Stopwatch
  class Stat
    getter count
    getter sec

    def initialize(@sec : Float64 = 0.0, @count : Int32 = 0)
    end                   

    def <<(stat : Stat)
      @sec   += stat.sec
      @count += stat.count
    end

    def to_s(io : IO)
      case @count
      when 0 ; io << "---"
      else   ; io << "%d (%.1f sec)" % [@count, @sec]
      end
    end
  end

  class Last < Stat
    def to_s(io : IO)
      io << "%.1f sec" % @sec
    end
  end

  getter total
  getter last

  property started_at : ::Time?
  delegate count, sec, to: total

  def initialize
    @total = Stat.new
    @last  = Last.new

    @started_at = nil
  end

  def start
    @started_at ||= ::Time.now
  end

  def stop
    if time = @started_at
      sec = (::Time.now - time).total_seconds
      @last = Last.new(sec, 1)
      @total << @last
      @started_at = nil
    end
  end

  def reset
    initialize
  end
  
  def measure
    start
    result = yield
    stop
    return result
  end
end
