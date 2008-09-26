module XssKiller
  module AttributeMethodsExtension
    module ClassMethods
      def self.included(base)
        base.class_eval do
          alias_method_chain :define_read_method, :xss_killing
        end
      end
      
      def define_read_method_with_xss_killing(symbol, attr_name, column)
        define_read_method_without_xss_killing symbol, attr_name, column
        if column.type == :string || column.type == :text
          class_eval <<-END, __FILE__, __LINE__
            def #{attr_name}_with_xss_killing
              value = #{attr_name}_without_xss_killing
              kill_xss #{column.name.inspect}, value
            end
          END
          alias_method_chain attr_name, "xss_killing"
        end
      end
    end
  end
  
  def self.included(base)
    base.class_eval do
      alias_method_chain :read_attribute, :xss_killing
    end
  end

  def read_attribute_with_xss_killing(attr_name)
    value = read_attribute_without_xss_killing
    if column = column_for_attribute(attr_name)
      if column.type == :text || column.type == :string
        return kill_xss(column.name, value)
      end
    end
    value
  end
end
