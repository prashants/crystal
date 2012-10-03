module Crystal
  class Exception < StandardError
    attr_accessor :node
    attr_accessor :inner

    def initialize(message, node = nil, inner = nil)
      @message = message
      @node = node
      @inner = inner
    end

    def message(source = nil)
      to_s(source)
    end
    
    def to_s(source = nil)
      lines = source ? source.lines.to_a : nil
      str = 'Error '
      append_to_s(str, lines)
      str
    end

    def append_to_s(str, lines)
      if node
        str << "in line #{node.line_number}: #{@message}"
      else
        str << "#{@message}"
      end
      if lines && node
        str << "\n\n"
        str << lines[node.line_number - 1].chomp
        if node.respond_to?(:name)
          str << "\n"
          if node.respond_to?(:name_column_number)
            str << (' ' * (node.name_column_number - 1))
          else
            str << (' ' * (node.column_number - 1))
          end
          str << '^'
          str << ('~' * (node.name.length - 1))
        end
      end
      str << "\n"
      if inner
        str << "\n"
        inner.append_to_s(str, lines) 
      end
    end
  end
end