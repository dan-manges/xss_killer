module XssKiller
  module ActionControllerExtension
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :render, :xss_killer
      end
    end

    def self.mime_type_for_handler(handler)
      case handler.class.name # TODO: not very ducky
      when "ActionView::TemplateHandlers::ERB"     then Mime::HTML.to_sym
      when "ActionView::TemplateHandlers::RJS"     then Mime::JS.to_sym
      when "ActionView::TemplateHandlers::Builder" then Mime::XML.to_sym
      end
    end

    def render_with_xss_killer(options = nil, extra_options = {}, &block)
      if options # explicit render
        mime_type = response.content_type ? Mime::Type.lookup(response.content_type.to_s).to_sym : Mime::HTML.to_sym  
      else # implicit render
        handler = ActionView::Template.new(@template, default_template_name, true).handler
        mime_type = ActionControllerExtension.mime_type_for_handler(handler) || raise("TODO: decide what to do")
      end

      XssKiller.rendering mime_type, @template do
        render_without_xss_killer options, extra_options, &block
      end
    end
  end
end