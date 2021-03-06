require "program"
require "visitor"
require "ast"
require "type_inference/*"

module Crystal
  class Program
    def infer_type(node)
      node.accept TypeVisitor.new(self)
      node
    end
  end

  class TypeVisitor < Visitor
    getter :mod

    def initialize(@mod, @vars = {} of String => Var, @scope = nil, @parent = nil, @call = nil, @owner = nil, @untyped_def = nil, @typed_def = nil, @arg_types = nil, @free_vars = nil, @yield_vars = nil)
      @types = [@mod] of Type
    end

    def visit(node : ASTNode)
      true
    end

    def visit(node : BoolLiteral)
      node.type = mod.bool
    end

    def visit(node : NumberLiteral)
      node.type = case node.kind
                  when :i8
                    mod.int8
                  when :i16
                    mod.int16
                  when :i32
                    mod.int32
                  when :i64
                    mod.int64
                  when :u8
                    mod.int8
                  when :u16
                    mod.int16
                  when :u32
                    mod.int32
                  when :u64
                    mod.int64
                  when :f32
                    mod.float32
                  when :f64
                    mod.float64
                  end
    end

    def visit(node : CharLiteral)
      node.type = mod.char
    end

    def visit(node : SymbolLiteral)
      node.type = mod.symbol
    end

    def visit(node : StringLiteral)
      node.type = mod.string
    end

    def visit(node : Var)
      var = lookup_var node.name
      node.bind_to var
    end

    def end_visit(node : Expressions)
      node.bind_to node.last unless node.empty?
    end

    def visit(node : Assign)
      type_assign node.target, node.value, node
    end

    def type_assign(target, value, node)
      value.accept self

      if target.is_a?(Var)
        var = lookup_var target.name
        target.bind_to var

        node.bind_to value
        var.bind_to node
      end

      false
    end

    def visit(node : Def)
      @mod.add_def node
      false
    end

    def visit(node : Call)
      node.mod = @mod
      node.parent_visitor = self
      node.args.each do |arg|
        arg.accept self
      end
      node.recalculate
      false
    end

    def visit(node : ClassDef)
      superclass = if node_superclass = node.superclass
                     lookup_ident_type node_superclass
                   else
                     mod.reference
                   end

      if node.name.names.length == 1 && !node.name.global
        # scope = current_type
        # name = node.name.names.first
      else
        # name = node.name.names.pop
        # scope = lookup_ident_type node.name
      end
    end

    def lookup_var(name)
      @vars.fetch_or_assign(name) { Var.new name }
    end

    def lookup_ident_type(node : Ident)
      # if @free_vars && !node.global && type = @free_vars[[node.names.first]]
      #   if node.names.length == 1
      #     target_type = type
      #   else
      #     target_type = type.lookup_type(node.names[1 .. -1])
      #   end
      # elsif node.global
      if node.global
        target_type = mod.lookup_type node.names
      else
        target_type = (@scope || @types.last).lookup_type node.names
      end

      unless target_type
        node.raise "uninitialized constant #{node}"
      end

      target_type
    end

    def lookup_ident_type(node)
      raise "lookup_ident_type not implemented for #{node}"
    end
  end
end
