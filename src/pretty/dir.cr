# `Pretty::Dir.clean(dir)` creates the dir and truncates all files there.
#
# ### Usage
#
# ```crystal
# Pretty::Dir.clean("tmp/test1")
# ```
require "file_utils"

module Pretty
  module Dir
    def self.clean(path : String)
      FileUtils.rm_rf(path) if File.exists?(path)
      FileUtils.mkdir_p(path)
    end
  end
end
