# `Pretty.truncate` returns a copy of its receiver truncated after a given length
#
# ### Usage
#
# ```crystal
# Pretty.truncate("Hello World", size: 3)  # => "Hel..."
# ```
module Pretty
  def self.truncate(text, size = 20)
    text = text.to_s
    if text.size > size
      return text.split(//)[0,size].join + "..."
    else
      return text
    end
  end
end
