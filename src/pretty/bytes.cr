# `Pretty.bytes` formats `Array(Array(String))` as table-like text.
#
# ### Usage
#
# ```crystal
# Pretty.bytes(416)  # => "416.0 B"
# Pretty.bytes(3819) # => "3.8 KB"
# ```
#
# ### original code
# - http://stackoverflow.com/questions/1094841/reusable-library-to-get-human-readable-version-of-file-size
module Pretty
  def self.bytes(bytes, block = 1000, suffix = "B")
    bytes = bytes.to_f
    block = block.to_f
    infix = (block == 1024) ? "i" : ""
    units = [""] + ["K", "M", "G", "T", "P", "E", "Z"].map(&.+ infix)
    units.each do |unit|
      if bytes.abs < block
        return "%.1f %s%s" % [bytes, unit, suffix]
      else
        bytes /= block
      end
    end
    return "%.1f %s%s" % [bytes, "Y#{infix}", suffix]
  end
end
