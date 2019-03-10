require "file_utils"

# - `Pretty::File.rm_f` acts as `rm -f path`
# - `Pretty::File.write` creates the dir first, then delegates to `File.write`
# - `Pretty.xxx` delegates to `FileUtils` about its methods.
#
# ### Usage
#
# ```crystal
# Pretty::File.rm_f("tmp/foo")
#
# Pretty::File.write("tmp/foo", "...")
# Dir.exists?("tmp") # => true
# ```
module Pretty
  module File
    {% for m in ::FileUtils.methods %}
      def {{m.name}}(*args, **options)
        ::FileUtils.{{m.name}}(*args, **options)
      end
    {% end %}

    def rm_f(path : String)
      ::File.delete(path) if ::File.exists?(path)
    end

    def write(path : String, *args, **opts)
      ::Dir.mkdir_p(::File.dirname(path))
      ::File.write(path, *args, **opts)
    end

    extend ::Pretty::File
  end

  extend ::Pretty::File
end
