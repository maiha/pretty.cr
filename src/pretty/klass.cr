# `klass` macro acts same as `record` macro except two points.
# 1. This uses `class` rather than `struct`.
# 2. This can accept subclass too.
#
# ### Usage
#
# ```crystal
# class NotFound < Exception
#   getter name
#
#   def initialize(@name : String)
#   end
# end
# ```
# This can be shortened as follows.
#
# ```crystal
# klass NotFound < Exception, name : String
# ```
macro klass(a, *properties)
  class {{ (a.is_a?(Call) && a.name == "<") ? "#{a.receiver} < #{a.args.first}".id : a.id }}
    {% for property in properties %}
      {% if property.is_a?(Assign) %}
        getter {{property.target.id}}
      {% elsif property.is_a?(TypeDeclaration) %}
        getter {{property.var}} : {{property.type}}
      {% else %}
        getter :{{property.id}}
      {% end %}
    {% end %}

    {% if properties.size > 0 %}
      def initialize({{ *properties.map{|field| "@#{field.id}".id} }})
      end
    {% end %}

    {{yield}}
  end
end
