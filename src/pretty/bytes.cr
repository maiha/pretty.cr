# `Pretty::Bytes` represents bytes information
#
# ### Usage
#
# ```crystal
# Pretty.bytes(416).to_s  # => "416 B"
# Pretty.bytes(3819).to_s # => "3.8 KB"
# ```

record Pretty::Bytes, bytes : Int64 do
  def_equals bytes

  def to_i : Int64
    bytes
  end

  def +(other)
    Bytes.new(bytes + other.bytes)
  end

  UNITS_WITH_POWER = {"K"=>1, "M"=>2, "G"=>3, "T"=>4, "P"=>5, "E"=>6, "Z"=>7, "Y"=>8}
  UNITS = UNITS_WITH_POWER.keys

  {% for unit, power in Pretty::Bytes::UNITS_WITH_POWER %}
    def {{unit.downcase.id}}b : Float64
      bytes / 1000.0 ** {{power}}
    end

    def {{unit.downcase.id}}ib : Float64
      bytes / 1024.0 ** {{power}}
    end
  {% end %}

  def formatter(block = 1024, prefix = "", suffix = "B")
    Formatter.new(self, block: block, prefix: prefix, suffix: suffix)
  end
  
  def to_s(io : IO, **opts)
    formatter(**opts).to_s(io)
  end
  
  def to_s(**opts) : String
    formatter(**opts).to_s
  end
  
  record Formatter, bytes : Bytes, block : Int32 = 1000, prefix : String = " ", suffix : String = "B" do
    def to_i : Int64
      @bytes.bytes
    end

    def to_s(io : IO)
      bytes = @bytes.bytes.to_f
      block = @block.to_f
      infix = (block == 1024) ? "i" : ""
      units = [""] + UNITS.map(&.+ infix)

      # http://stackoverflow.com/questions/1094841/reusable-library-to-get-human-readable-version-of-file-size
      while unit = units.shift?
        break if bytes.abs < block
        bytes /= block
      end

      num = "%.1f" % bytes
      case num
      when /^\d{3,}/, /^\.0$/
        num = num.sub(/\..+/, "")
      else
      end
      io << "%s%s%s%s" % [num, prefix, unit, suffix]
    end
  end
    
  def self.zero
    new(0)
  end

  def self.parse?(v) : Bytes?
    case v.strip
    when /^(\d+(\.\d+)?)\s*([KMGTPEZY])?(iB|B)?/
      num = $1.to_f64
      unit = $~[3]?
      block = ($~[4]? == "B") ? 1000 : 1024

      if u = unit
        power = UNITS_WITH_POWER[u]? || raise "BUG: Pretty::Bytes can't find power of unit(#{unit.inspect})"
        num = num * block ** power
      end

      new(num.to_i64)
    else
      return nil
    end
  end

  def self.parse(v) : Bytes
    parse?(v) || raise ArgumentError.new("Invalid Pretty::Bytes: #{v.inspect}")
  end
end

# new format by string
def Pretty.bytes(s : String)
  Pretty::Bytes.parse(s)
end

# backward compatibility (old api)
def Pretty.bytes(v : Int, block = 1000, prefix = " ", suffix = "B")
  Pretty::Bytes.new(v.to_i64).formatter(block: block, prefix: prefix, suffix: suffix)
end

# backward compatibility (non int)
def Pretty.bytes(v)
  Pretty::Bytes.parse(v.to_s)
end

