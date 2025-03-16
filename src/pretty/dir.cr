# `Pretty::Dir.clean(dir)` creates the dir and truncates all files there.
#
# ### Usage
#
# ```
# Pretty::Dir.clean("tmp/test1")
# ```
require "./file"

module Pretty
  module Dir
    def self.clean(path : String)
      ::Pretty.rm_rf(path) if ::File.exists?(path)
      ::Pretty.mkdir_p(path)
    end
  end
end
