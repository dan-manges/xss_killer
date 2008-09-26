module XssKiller
  module ActiveRecordExtension
    module ClassMethods
      def kills_xss(options = {})
        @xss_killer_options = options
        @xss_killer_options[:allow_injection] ||= []
        @xss_killer_options[:allow_injection].map!(&:to_s)
        @xss_killer_options[:sanitize] ||= []
        @xss_killer_options[:sanitize].map!(&:to_s)
        @kill_xss = true
      end
      
      def kill_xss?
        @kill_xss
      end

      def xss_killer_options
        @xss_killer_options || {}
      end
    end

    def kill_xss(column_name, value)
      return value unless value.is_a?(String)
      return value unless self.class.kill_xss?
      return value unless XssKiller.rendering_html?
      if self.class.xss_killer_options[:allow_injection].include?(column_name.to_s)
        value
      elsif self.class.xss_killer_options[:sanitize].include?(column_name.to_s)
        sanitized = XssKiller.template.sanitize value
        formatted = XssKiller.template.simple_format sanitized
      else
        ERB::Util.html_escape value
      end
    end
  end
end
