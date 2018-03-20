# `Pretty.diff(a,b)` analizes the difference, and returns a `Pretty::Diff`
# `Pretty::Diff` provides `Iterable(Pretty::Diff::Entry)`
#
# ### Usage
#
# ```crystal
# Pretty.diff(1, nil).to_s  # => "Expected 'Int32', but got 'Nil'"
# ```
module Pretty
  def self.diff(*args, **opts)
    Diff.diff(*args, **opts)
  end
end

class Pretty::Diff
  record Entry, message : String, index : Int32 = 0 do
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

  def self.diff(a, b, value_truncate : Int32 = 30) : Diff
    return new(type_mismatch(a.class, b.class)) if a.class != b.class
    return ok if a == b

    if a.is_a?(Enumerable) && b.is_a?(Enumerable)
      diffs = Array(Diff).new
      (0...[a.size, b.size].max).to_a.each_with_index do |v i|
        entry = diff(a[v]?, b[v]?, value_truncate)
        diffs << entry
      end
      return new(diffs)
    else
      return new(value_mismatch(a, b, truncate: value_truncate))
    end
  end
  
  private def self.ok : Diff
    new(Array(Entry).new)
  end

  private def self.type_mismatch(c1, c2, prefix : String = "") : Entry
    Entry.new("#{prefix}Expected '#{c1}', but got '#{c2}'")
  end

  private def self.value_mismatch(v1, v2, truncate : Int32) : Entry
    v1 = Pretty.truncate(v1, size: truncate)
    v2 = Pretty.truncate(v2, size: truncate)
    type_mismatch(v1, v2)
  end

  private def self.size_mismatch(s1, s2) : Entry
    Entry.new("Expected %d items, but got %d" % [s1, s2])
  end
end

