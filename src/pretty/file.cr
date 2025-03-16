require "file_utils"

# - `Pretty::File.rm_f` acts as `rm -f path`
# - `Pretty::File.write` creates the dir first, then delegates to `File.write`
# - `Pretty.xxx` delegates to `FileUtils` about its methods.
#
# ### Usage
#
# ```
# Pretty::File.rm_f("tmp/foo")
#
# Pretty::File.write("tmp/foo", "...")
# Dir.exists?("tmp") # => true
#
# Pretty.expand_path("~/")
# ```
module Pretty
  module File
    {% for m in ::FileUtils.methods %}
      def {{m.name}}(*args, **options)
        ::FileUtils.{{m.name}}(*args, **options)
      end
    {% end %}

    def mtime(path : String)
      ::File.info(path).modification_time
    end

    def rm_f(path : String)
      ::File.delete(path) if ::File.exists?(path)
    end

    def write(path : String, *args, **opts)
      ::Dir.mkdir_p(::File.dirname(path))
      ::File.write(path, *args, **opts)
    end

    # backward compatibility until 0.31.0 or lower
    {% if ::Crystal::VERSION =~ /^0\.(1\d|2\d|3[01])\./ %}
      def expand_path(path, dir = nil) : String
        ::File.expand_path(path, dir)
      end
    {% else %}
      # 'expand' should expand :)
      def expand_path(path, dir = nil, *, home = true) : String
        ::Path.new(path).expand(dir || ::Dir.current, home: home).to_s
      end
    {% end %}

    extend ::Pretty::File
  end

  extend ::Pretty::File
end
