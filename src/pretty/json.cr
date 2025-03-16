require "json"

module Pretty
  def self.json(json : String, color : Bool = false) : String
    input = IO::Memory.new(json)
    buf = String.build do |output|
      Pretty::Json::Printer.new(input, output).print
    end
    unless color
      # We are using original color-aware code, so need to strip colors.
      buf = buf.gsub(/\x1B\[[0-9;]*[mK]/, "")
    end
    return buf
  end

  # https://github.com/crystal-lang/crystal/blob/master/samples/pretty_json.cr
  class Json::Printer
    def initialize(@input : IO, @output : IO)
      @pull = JSON::PullParser.new @input
      @indent = 0
    end

    def print
      read_any
    end

    {% if ::Crystal::VERSION =~ /^0\.[12]/ %}
      def read_any
        case @pull.kind
        when :null
          Pretty::Colorize.surround(@output, bold) do
            @pull.read_null.to_json(@output)
          end
        when :bool
          Pretty::Colorize.surround(@output, light_blue) do
            @pull.read_bool.to_json(@output)
          end
        when :int
          Pretty::Colorize.surround(@output, red) do
            @pull.read_int.to_json(@output)
          end
        when :float
          Pretty::Colorize.surround(@output, red) do
            @pull.read_float.to_json(@output)
          end
        when :string
          Pretty::Colorize.surround(@output, yellow) do
            @pull.read_string.to_json(@output)
          end
        when :begin_array
          read_array
        when :begin_object
          read_object
        when :EOF
          # We are done
        end
      end
    {% elsif ::Crystal::VERSION =~ /^0\.3[0-4]/ %}
      # 0.30.0 breaks compatibility: kind is changed from Symbol to Enum
      def read_any
        case @pull.kind
        when .null?
          Pretty::Colorize.surround(@output, bold) do
            @pull.read_null.to_json(@output)
          end
        when .bool?
          Pretty::Colorize.surround(@output, light_blue) do
            @pull.read_bool.to_json(@output)
          end
        when .int?
          Pretty::Colorize.surround(@output, red) do
            @pull.read_int.to_json(@output)
          end
        when .float?
          Pretty::Colorize.surround(@output, red) do
            @pull.read_float.to_json(@output)
          end
        when .string?
          Pretty::Colorize.surround(@output, yellow) do
            @pull.read_string.to_json(@output)
          end
        when .begin_array?
          read_array
        when .begin_object?
          read_object
        when .eof?
          # We are done
        else
          raise "Bug: unexpected kind: #{@pull.kind}"
        end
      end
    {% else %}
      # 0.35 or higher
      def read_any
        case @pull.kind
        when .null?
          Pretty::Colorize.surround(@output, bold) do
            @pull.read_null.to_json(@output)
          end
        when .bool?
          Pretty::Colorize.surround(@output, light_blue) do
            @pull.read_bool.to_json(@output)
          end
        when .int?
          Pretty::Colorize.surround(@output, red) do
            @pull.read_int.to_json(@output)
          end
        when .float?
          Pretty::Colorize.surround(@output, red) do
            @pull.read_float.to_json(@output)
          end
        when .string?
          Pretty::Colorize.surround(@output, yellow) do
            @pull.read_string.to_json(@output)
          end
        when .begin_array?
          read_array
        when .begin_object?
          read_object
        when .eof?
          # We are done
        else
          raise "Bug: unexpected kind: #{@pull.kind}"
        end
      end
    {% end %}

    def read_array
      print "[\n"
      @indent += 1
      i = 0
      @pull.read_array do
        if i > 0
          print ','
          print '\n' if @indent > 0
        end
        print_indent
        read_any
        i += 1
      end
      @indent -= 1
      print '\n'
      print_indent
      print ']'
    end

    def read_object
      print "{\n"
      @indent += 1
      i = 0
      @pull.read_object do |key|
        if i > 0
          print ','
          print '\n' if @indent > 0
        end
        print_indent
        Pretty::Colorize.surround(@output, cyan) do
          key.to_json(@output)
        end
        print ": "
        read_any
        i += 1
      end
      @indent -= 1
      print '\n'
      print_indent
      print '}'
    end

    def print_indent
      @indent.times { @output << "  " }
    end

    def print(value)
      @output << value
    end
  end
end
