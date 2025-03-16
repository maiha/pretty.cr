# `Pretty.error` provides simple backtraces.
# - `#where` returns the first meaningful backtrace by skipping internal lines
#
# ### Usage
#
# ```
# err.backtrace           # => ["0x48df77: *CallStack::unwind:Array(Pointer(Void))
# Pretty.error(err).where # => "mysql at src/commands/db.cr 20:3"
# ```
module Pretty
  def self.error(err : Exception)
    Error.new(err)
  end

  class Error
    getter message : String

    def initialize(@err : Exception)
      @message = "#{@err}" + ((@err.class != Exception) ? " (#{@err.class})" : "")
    end

    def to_s(io : IO)
      io << message
      if w = where?
        io << "\n" << w
      end
    end

    def where?
      self.class.where?(backtrace)
    end

    def where
      where? || ""
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

    def self.where?(msg, work_dir : String = APP_ROOT) : String?
      work_dir = work_dir.chomp("/")

      if Crystal.version.minor < 24
        return Error::Backtrace::V023.where?(msg, work_dir)
      else
        return Error::Backtrace::V024.where?(msg, work_dir)
      end
    end
  end

  module Error::Backtrace
    CRENV_RE = %r{/.crenv/}
    SHARD_RE = %r{/lib/[^/]+/src/}
    # abstract def self.where?(msg, work_dir) : String?
  end

  module Error::Backtrace::V023
    include Error::Backtrace

    def self.where?(msg, work_dir) : String?
      # 0x4b5f97: *CallStack::unwind:Array(Pointer(Void)) at ??
      # 0x582604: foo at /home/maiha/pretty.cr/spec/error_spec.cr 5:5
      # 0x4af5e1: ~procProc(Nil) at /data/crystal/0.23.1/src/kernel.cr 76:3
      msg.scan(/^0x[0-9a-f]+:([^\n]+?) at (\/[^\n]+?)$/m) do |m|
        why = m[1].to_s.strip
        path = m[2].to_s.strip
        case path
        when SHARD_RE # ignore
        when CRENV_RE # ignore
        else
          if !work_dir.empty? && path.starts_with?(work_dir)
            path = path[(work_dir.size + 1)..-1]
          end
          return "#{why} at #{path}"
        end
      end
      return nil
    end
  end

  module Error::Backtrace::V024
    include Error::Backtrace

    def self.where?(msg, work_dir) : String?
      # foo (Exception)
      #   from spec/error_spec.cr:5:5 in 'foo'
      #   from /data/crystal/0.24.1/src/kernel.cr:28:5 in '~procProc(Nil)'

      msg.scan(/^\s*from (\S+?) in (\S+?)$/m) do |m|
        path = m[1].to_s.strip
        why = m[2].to_s.strip
        case path
        when SHARD_RE # ignore
        when CRENV_RE # ignore
        else
          if !work_dir.empty? && path.starts_with?(work_dir)
            path = path[(work_dir.size + 1)..-1]
          end
          return "#{why} at #{path}"
        end
      end
      return nil
    end
  end
end
