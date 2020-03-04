# 0.30.1 (2019-08-12)
# - **(breaking-change)** Improve URL encoding. `URI.escape` and `URI.unescape` are renamed to `URI.encode_www_form` and `URI.decode_www_form`. Add `URI.encode` and `URI.decode`. ([#7997](https://github.com/crystal-lang/crystal/pull/7997), [#8021](https://github.com/crystal-lang/crystal/pull/8021), thanks @straight-shoota, @bcardiff)

require "uri"

module Pretty
  module URI
    def self.escape(path : String, *args, **opts) : String
      {% if ::Crystal::VERSION =~ /^0\.[12]\d\./ %}
        ::URI.escape(path, *args, **opts)
      {% else %}
        ::URI.encode_www_form(path, *args, **opts)
      {% end %}
    end

    def self.unescape(path : String, *args, **opts) : String
      {% if ::Crystal::VERSION =~ /^0\.[12]\d\./ %}
        ::URI.unescape(path, *args, **opts)
      {% else %}
        ::URI.decode_www_form(path, *args, **opts)
      {% end %}
    end
  end
end
