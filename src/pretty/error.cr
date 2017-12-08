# `Pretty.error` provides simple backtraces.
# - `#where` returns the first meaningful backtrace.
#
# ### Usage
#
# ```crystal
# err.backtrace            # => ["0x48df77: *CallStack::unwind:Array(Pointer(Void))
# Pretty.error(err).where  # => "foo at spec/error_spec.cr 5:5"
# ```
module Pretty
  def self.error(err : Exception)
    Error.new(err)
  end

  class Error
    def initialize(@err : Exception)
    end

    def to_s(io : IO)
      io << @err.to_s
      io << " (#{@err.class})" if @err.class != Exception
      if w = where
        io << "\n" << w
      end
    end
  
    def where
      self.class.where(backtrace)
    end
  
    def backtrace : String
      String.build do |io|
        @err.inspect_with_backtrace(io)
      end
    end
  end
end

module Pretty
  class Error
    APP_ROOT = {{ env("PWD") }}
    CRENV_RE = %r{/.crenv/}
    SHARD_RE = %r{/lib/}

    def self.where(msg, root = APP_ROOT)
      root = root.chomp("/") + "/" if !root.empty?
      msg.scan(/^0x[0-9a-f]+:([^\n]+?) at (\/[^\n]+?)$/m) do |m|
        why  = m[1].to_s.strip
        path = m[2].to_s.strip
        if path.starts_with?(root)
          path = path[root.size .. -1]
        end
        case path
        when SHARD_RE # ignore
        when CRENV_RE # ignore
        else
          return "#{why} at #{path}"
        end
      end
      return ""
    end
  end
end
