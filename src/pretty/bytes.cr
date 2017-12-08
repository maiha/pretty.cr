# `Pretty.bytes` formats `Array(Array(String))` as table-like text.
#
# ### Usage
#
# ```crystal
# Pretty.bytes(416)  # => "416 B"
# Pretty.bytes(3819) # => "3.8 KB"
# ```
#
# ### original code
# - http://stackoverflow.com/questions/1094841/reusable-library-to-get-human-readable-version-of-file-size
module Pretty
  def self.bytes(bytes, block = 1000, prefix = " ", suffix = "B")
    bytes = bytes.to_f
    block = block.to_f
    infix = (block == 1024) ? "i" : ""
    units = [""] + ["K", "M", "G", "T", "P", "E", "Z", "Y"].map(&.+ infix)

    while unit = units.shift?
      break if bytes.abs < block
      bytes /= block
    end

    num = "%.1f" % bytes
    case num
    when /^\d{3,}/, /^\.0$/
      num = num.sub(/\..+/, "")
    end
    return "%s%s%s%s" % [num, prefix, unit, suffix]
  end
end
