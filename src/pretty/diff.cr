# `Pretty.diff(a,b)` analizes the difference, and returns a `Pretty::Diff`
# `Pretty::Diff` provides `Iterable(Pretty::Diff::Entry)`
#
# ### Usage
#
# ```crystal
# Pretty.diff(1, nil).to_s  # => "Expected 'Int32', but got 'Nil'"
# ```
module Pretty
  def self.diff(a, b, size : Int32 = 60)
    Diff.diff(a,b).tap(&.output_size = size)
  end
end

class Pretty::Diff
  record Entry, message : String do
    delegate to_s, to: message
  end

  include Enumerable(Entry)
  delegate each, to: @entries

  include Iterable(Entry)

  getter entries
  property? output_size : Int32?
  
  def initialize(@entries : Array(Entry))
  end

  def to_s(io : IO)
    buf = String.build do |s|
      case size
      when 0
      when 1
        s << first.message
      else
        each_with_index do |e, i|
          s << "," if i > 0
          s << e.message
        end
      end
    end
    if limit = output_size?
      io << Pretty.truncate(buf, size: limit)
    else
      io << buf
    end
  end

  def self.new(e : Entry) : Diff
    new([e])
  end

  def self.new(array : Array(Diff)) : Diff
    entries = [] of Entry
    array.each do |diff|
      if diff.size > 0
        entries << Entry.new(diff.to_s)
      end
    end
    new(entries)
  end

  def self.diff(a,b) : Diff
    return new(type_mismatch(a.class, b.class)) if a.class != b.class
    return ok if a == b

    if a.is_a?(Enumerable) && b.is_a?(Enumerable)
      diffs = (0...[a.size, b.size].max).map{|i| diff(a[i]?, b[i]?).as(Diff)}
      return new(diffs)
    else
      return new(value_mismatch(a, b))
    end
  end
  
  private def self.ok : Diff
    new(Array(Entry).new)
  end

  private def self.type_mismatch(c1, c2) : Entry
    Entry.new("Expected '%s', but got '%s'" % [c1, c2])
  end

  private def self.value_mismatch(v1, v2) : Entry
    v1 = Pretty.truncate(v1, size: 30)
    v2 = Pretty.truncate(v2, size: 30)
    Entry.new("Expected '%s', but got '%s'" % [v1, v2])
  end

  private def self.size_mismatch(s1, s2) : Entry
    Entry.new("Expected %d items, but got %d" % [s1, s2])
  end
end

