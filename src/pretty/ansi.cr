module Pretty::Ansi
  # ```crystal
  # Pretty.remove_ansi("foo".colorize(:green)) # => "foo"
  # ```
  def remove_ansi(v)
    v.to_s.gsub(/\e\[(\d+;)?(\d+)m/, "")
  end
end

module Pretty
  extend Ansi
end
