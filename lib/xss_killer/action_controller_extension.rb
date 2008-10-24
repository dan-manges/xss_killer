module XssKiller
  module ActionControllerExtension
    module ExplicitRender
      def mime_type
        response.content_type ? Mime::Type.lookup(response.content_type.to_s).to_sym : Mime::HTML.to_sym  
      end
    end
    
    module ImplicitRender
      def mime_type
        mime_type_method = "mime_type_for_rails_#{Rails::VERSION::MAJOR}_#{Rails::VERSION::MINOR}"
        if respond_to?(mime_type_method)
          send(mime_type_method)
        else
          raise "Rails #{Rails::VERSION::STRING} is not supported"
        end
      end
      
      def mime_type_for_rails_2_2
        template = @template.send(:_pick_template, default_template_name)
        template.mime_type || ActionControllerExtension.mime_type_for_handler(template.handler) || raise("TODO: decide what to do")
      end

      def mime_type_for_rails_2_1
        handler = ActionView::Template.new(@template, default_template_name, true).handler.class
        ActionControllerExtension.mime_type_for_handler(handler) || raise("TODO: decide what to do")
      end

      def mime_type_for_rails_2_0
        ext = @template.send :find_template_extension_for, default_template_name
        handler = ActionView::Base.handler_for_extension(ext)
        ActionControllerExtension.mime_type_for_handler(handler) || raise("TODO: decide what to do")
      end
    end
    
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :render, :xss_killer
      end
    end

    def self.mime_type_for_handler(handler_class)
      case handler_class.name # TODO: not very ducky
      when "ActionView::TemplateHandlers::ERB"     then Mime::HTML.to_sym
      when "ActionView::TemplateHandlers::RJS"     then Mime::JS.to_sym
      when "ActionView::TemplateHandlers::Builder" then Mime::XML.to_sym
      end
    end

    def render_with_xss_killer(options = nil, extra_options = {}, &block)
      extend(options ? ExplicitRender : ImplicitRender)
      XssKiller.rendering mime_type, @template do
        render_without_xss_killer options, extra_options, &block
      end
    end
  end
end
