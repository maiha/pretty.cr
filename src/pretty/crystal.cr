module Pretty::Crystal
  # ```crystal
  # version = Pretty::Crystal.version
  # version.major       # => 0
  # version.minor       # => 27
  # version.rev         # => 2
  # version.build       # => "dev"
  # version.to_s        # => "0.27.2-dev"
  # Crystal::VERSION    # => "0.27.2-dev"
  # ```
  VERSION = (Version.parse(::Crystal::VERSION) rescue Version.new)

  def self.version
    VERSION
  end
end
