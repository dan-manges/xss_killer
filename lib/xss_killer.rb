require "xss_killer/action_controller_extension"
require "xss_killer/attribute_methods_extension"
require "xss_killer/active_record_extension"

ActiveRecord::Base.extend XssKiller::ActiveRecordExtension::ClassMethods
ActiveRecord::Base.send :include, XssKiller::ActiveRecordExtension
ActiveRecord::AttributeMethods::ClassMethods.send :include, XssKiller::AttributeMethodsExtension::ClassMethods
ActiveRecord::AttributeMethods.send :include, XssKiller::AttributeMethodsExtension
ActionController::Base.send :include, XssKiller::ActionControllerExtension

module XssKiller
  @rendering = false

  def self.render_format
    @render_format
  end

  def self.rendering?
    @rendering
  end
  
  def self.rendering_html?
    @rendering && @render_format == :html
  end
  
  def self.rendering(format, template, &block)
    @template = template
    @render_format = format
    @rendering = true
    yield
  ensure
    @render_format = nil
    @rendering = false
    @template = nil
  end
  
  def self.template
    @template
  end
end
