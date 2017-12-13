# `Pretty.camelize` convert string to camel case
# `Pretty.classify` convert string to pascal case
# `Pretty.underscore` is almost same as `String#underscore` except the case of digit + upcase
#
# ### Usage
#
# ```crystal
# Pretty.camelize
# Pretty.classify
# Pretty.underscore("a1Id") # => "a1_id"
# ```

module Pretty
  def self.camelize(str : String)
    str.underscore.downcase.gsub(/(_.)/){|i| i.delete("_").upcase}
  end

  def self.classify(str : String)
    camelize(str).sub(/^./){|i| i.upcase}
  end

  def self.underscore(str : String)
    str.gsub(/(\d)([A-Z])/){ "#{$1}_#{$2}" }.underscore
  end
end
