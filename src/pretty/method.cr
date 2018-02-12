module Pretty
  class Method(T)
    class NotFound < Exception
    end

    def initialize(@instance : T)
    end

    def call(method_name : String)
      self.class.call(@instance, method_name)
    end

    def call?(method_name : String)
      self.class.call?(@instance, method_name)
    end

    def self.call(instance : T, method_name : String)
      # ignore: when the body string contains `yield` bacause `block_arg` can't detect it when using `yield`
      # ignore: Array#transpose that breaks compilation
      {% for m in T.methods %}
        {% if m.visibility == :public && m.args.size == 0 && !m.splat_index && !m.double_splat && !m.block_arg && m.name.stringify =~ /[^=]$/ %}
          {% if !(m.body.stringify =~ /\byield\b/) %}
            {% if !(T.name.stringify =~ /^Array\b/ && m.name == "transpose") %}
              return instance.{{m.name.id}} if method_name == "{{m.name}}"
            {% end %}
          {% end %}
        {% end %}
      {% end %}
      raise NotFound.new("%s#%s" % [{{T.name.stringify}}, method_name])
    end

    def self.call?(instance : T, method_name : String)
      call(instance, method_name)
    rescue NotFound
      nil
    end
  end
end

module Pretty
  def self.method(obj)
    Pretty::Method.new(obj)
  end
end
