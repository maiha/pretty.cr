require "colorize"

module Pretty::Colorize
  macro surround(io, color)
    {% if ::Crystal::VERSION =~ /^0\.(1|2|3[0-4])/ %}
      with_color.{{color}}.surround({{io}}) do
        {{yield}}
      end
    {% else %}
      ::Colorize.with.{{color}}.surround({{io}}) do
        {{yield}}
      end
    {% end %}
  end
end
