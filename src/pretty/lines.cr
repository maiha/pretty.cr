# `Pretty.lines` formats `Array(Array(String))` as table-like text.
#
# ### Usage
#
# ```crystal
# lines = [
#   ["user", "=", "maiha"],
#   ["password", "=", "123"],
# ]
# puts Pretty.lines(lines, delimiter: " ")
# ```
#
# prints
#
# ```
# user     = maiha
# password = 123
# ```
module Pretty
  def self.lines(lines : Array(Array(String)), indent : String = "", delimiter : String = "") : String
    if lines.empty?
      return ""
    else
      sample = lines[0]
      widths = (0...sample.size).map{|i| lines.map(&.[i].size).max}
      format = widths.map_with_index{|w,i| (i==widths.size-1) ? "%s" : "%-#{w}s"}.join(delimiter)
      return lines.map{|row| indent + (format % row)}.join("\n")
    end
  end
end
