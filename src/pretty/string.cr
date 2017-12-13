# `Pretty.camelize` convert string to camel case
# `Pretty.classify` convert string to pascal case
#
# ### Usage
#
# ```crystal
# Pretty.camelize
# Pretty.classify
# ```

module Pretty
  def self.camelize(str : String)
    str.underscore.downcase.gsub(/(_.)/){|i| i.delete("_").upcase}
  end

  def self.classify(str : String)
    camelize(str).sub(/^./){|i| i.upcase}
  end
end
