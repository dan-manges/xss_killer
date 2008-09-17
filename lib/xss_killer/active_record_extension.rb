module XssKiller
  module ActiveRecordExtension
    module ClassMethods
      def kill_xss(options = {})
        include XssKiller::ActiveRecordExtension
        @xss_killer_options = options
      end

      def xss_killer_options
        @xss_killer_options || {}
      end
    end

    def self.included(base)
      base.class_eval do
        after_find :track_for_xss_killing
        after_initialize :track_for_xss_killing
      end
    end

    def kill_xss(template)
      @template = template
      extend html_escaping_module
    end

    def after_find
    end

    def after_initialize
    end

    def track_for_xss_killing
      XssKiller.track self
    end

    protected

    def html_escaping_module
      if self.class.const_defined?("XSSKilling")
        return self.class.const_get("XSSKilling")
      end
      if !self.class.generated_methods?
        self.class.define_attribute_methods
      end
      mod = Module.new
      self.class.columns.each do |column|
        next unless [:string, :text].include?(column.type)
        mod.module_eval <<-END, __FILE__, __LINE__
          def #{column.name}(kill_xss = true)
            value = super()
            if value.is_a?(String) && kill_xss
              if self.class.xss_killer_options[:allow_injection] &&
                   self.class.xss_killer_options[:allow_injection].map(&:to_s).include?(#{column.name.to_s.inspect})
                value
              elsif self.class.xss_killer_options[:sanitize] &&
                self.class.xss_killer_options[:sanitize].map(&:to_s).include?(#{column.name.to_s.inspect})
                sanitized = @template.sanitize value
                formatted = @template.simple_format sanitized
              else
                ERB::Util.html_escape value
              end
            else
              value
            end
          end
        END
      end
      self.class.const_set "XSSKilling", mod
    end
  end
end
