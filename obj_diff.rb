class ObjDiff
  class Error
    attr_reader(:msg)
    attr_reader(:property)
    attr_reader(:lhs)
    attr_reader(:rhs)

    def initialize(msg, property, lhs, rhs)
      @msg = msg
      @property = property
      @lhs = lhs
      @rhs = rhs
    end

    def to_s
      "Diff on #{escape(@msg, 94)} at #{escape(@property, 93)}:\n  < #{escape(@lhs, 92)}\n  !=\n  > #{escape(@rhs, 91)}"
    end

    def inspect
      to_s
    end

    private

    def escape(s, color_code)
      "\e[#{color_code}m#{s}\e[0m"
    end
  end

  class << self
    def [](lhs, rhs)
      diff(lhs, rhs)
    end

    #
    # @return Bool
    #
    def diff(lhs, rhs, property = '_', visited = [])
      return if lhs == rhs
      return if visited.include?(lhs.object_id)
      visited << lhs.object_id

      return Error.new("type", property, lhs.class, rhs.class) if rhs.class != lhs.class

      case lhs
      when String, Numeric, Symbol, TrueClass, FalseClass, NilClass
        return Error.new('value', property, lhs, rhs) if lhs != rhs
      when Hash
        return Error.new("keys", property, lhs.keys.sort, rhs.keys.sort) if lhs.keys != rhs.keys

        lhs.keys.each do |key|
          printable_key = if simple_key?(key)
            "[#{key.inspect.gsub('"', '\'')}]"
          else
            ".values[#{lhs.keys.index(key)}]"
          end
          result = diff(lhs[key], rhs[key], property + "#{printable_key}", visited)
          return result unless result.nil?
        end
      when Enumerable
        return Error.new("enum size", property, lhs.to_a.size, rhs.to_a.size) if lhs.to_a.size != rhs.to_a.size

        if order_sensitive_type?(lhs)
          lhs.to_a.zip(rhs.to_a).each_with_index do |(lhs_val, rhs_val), index|
            result = diff(lhs_val, rhs_val, property + "[#{index}]", visited)
            return result unless result.nil?
          end
        else
          lhs_list = lhs.to_a
          rhs_list = rhs.to_a.clone
          
          lhs_list.each_with_index do |lhs_item, index|
            rhs_idx = rhs_list.find_index(lhs_item)
            return Error.new("enum item", property + "[#{index}]", lhs_item, nil) if rhs_idx.nil?

            rhs_list.delete_at(rhs_idx)
          end
        end
      else # PORO
        lhs_vars = lhs.instance_variables
        rhs_vars = rhs.instance_variables
        return Error.new("variables", property, lhs_vars, rhs_vars) if lhs_vars != rhs_vars

        lhs_vars.each do |var_name|
          lhs_var = lhs.instance_variable_get(var_name)
          rhs_var = rhs.instance_variable_get(var_name)

          result = diff(lhs_var, rhs_var, property + ".#{var_name[1..-1]}", visited)
          return result unless result.nil?
        end
      end
    end

    def simple_key?(key)
      case key
      when String, Numeric, Symbol, TrueClass, FalseClass, NilClass then true
      else false
      end
    end

    def order_sensitive_type?(o)
      case o
      when Array then true
      else false
      end
    end
  end
end
