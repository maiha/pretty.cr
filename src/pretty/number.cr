# `Pretty.number` shows number string with adding commas to the large numbers
#
# ### Usage
#
# ```crystal
# Pretty.number(10)       # => "10"
# Pretty.number(1000000)  # => "1,000,000"
# ```
#
# ### original code
# - https://stackoverflow.com/questions/1078347/is-there-a-rails-trick-to-adding-commas-to-large-numbers
module Pretty
  def self.number(n : Int)
    n.to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1,").reverse
  end
end
