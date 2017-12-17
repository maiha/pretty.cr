module Pretty
  CRYSTAL_UNDER_024 =
    {% if Crystal::VERSION =~ /^0\.(\d|1\d|2[0-3])\./ %}
      true
    {% else %}
      false
    {% end %}
end

require "./pretty/*"
