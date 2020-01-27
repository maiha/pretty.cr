# `Pretty::Bar` builds Ascii-art bar string for the `val` and `max`
#
# ```crystal
# bar = Pretty::Bar.new(val: 43, max: 176, width: 30)
# bar.val   # => 43
# bar.val_s # => " 43/176"
# bar.max   # => 176
# bar.width # => 30
# bar.mark  # => "|"
# bar.empty # => " "
# bar.bar   # => "|||||||                       "
# bar.pct   # => 24
# bar.pct_s # => " 24%"
# bar.to_s  # => "[|||||||                       ]  43/176 ( 24%)"
# ```
class Pretty::Bar
  getter val
  getter max
  getter width
  getter mark
  getter empty

  def initialize(@val : Int32, @max : Int32, @width : Int32 = 68, @mark : String = "|", @empty : String = " ")
    raise ArgumentError.new("#{self.class}: max < val (#{max}, #{val})") if max < val
  end

  # => "|||||||                       "
  def bar
    mark_width  = width_for(val)
    empty_width = width - mark_width
    
    String.build do |s|
      s << mark  * mark_width
      s << empty * empty_width
    end
  end

  # => 24
  def pct : Int32
    return 0 if max == 0

    case v = val * 100.0 / max
    when        0 ; 0
    when  0...  1 ; 1
    when 99...100 ; 99
    else          ; v.trunc.to_i32
    end
  end

  # => " 43/176"
  def val_s : String
    size = max.to_s.size
    "%#{size}s/%#{size}s" % [val, max]
  end

  # => " 24%"
  def pct_s : String
    "%3s%%" % pct
  end

  # => "[|||||||                       ]  43/176 (24%)"
  def to_s(io : IO)
    io << "[#{bar}] #{val_s} (#{pct_s})"
  end
  
  private def width_for(v : Int32) : Int32
    return 0 if max == 0
    w = v.to_f * width / max
    return 0 if w == 0
    return 1 if w < 1
    return w.trunc.to_i32
  end
end

module Pretty
  def self.bar(*args, **opts)
    Pretty::Bar.new(*args, **opts)
  end
end
