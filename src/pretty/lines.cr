# `Pretty.lines` formats `Array(Array(String))` as table-like text.
#
# ### Usage
#
# ```crystal
# lines = [
#   ["user", "maiha"],
#   ["password", "123"],
# ]
# puts Pretty.lines(lines, delimiter: " = ")
# ```
#
# prints
#
# ```
# user     = maiha
# password = 123
# ```
module Pretty
  def self.lines(lines : Array(Array(String)), headers : Array(String)? = nil, indent : String = "", delimiter : String = "") : String
    if ary = headers
      lines = [ary] + lines
    end

    if lines.empty?
      return ""
    else
      max_item_size = lines.map(&.size).max
      widths = (0...max_item_size).map{|i|
        lines.map{|row|
          if s = row[i]?
            Pretty.string_width(s)
          else
            0
          end
        }.max
      }

      if headers
        lines[1..0] = widths.map{|i| "-"*i}
      end
      
      return String.build do |s|
        lines.each do |row|
          s << indent
          widths.each_with_index do |width, i|
            v = row[i]? || ""
            s << v
            # adjust spaces
            rest = width - Pretty.string_width(v)
            if rest > 0
              s << " " * rest
            end
            s << delimiter if i < widths.size - 1
          end
          s << "\n"
        end
      end.chomp
    end
  end
end
