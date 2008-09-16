require "xss_killer/action_controller_extension"
require "xss_killer/active_record_extension"

ActiveRecord::Base.send :include, XssKiller::ActiveRecordExtension
ActiveRecord::Base.extend XssKiller::ActiveRecordExtension::ClassMethods
ActionController::Base.send :include, XssKiller::ActionControllerExtension

module XssKiller
  @records_to_escape = []
  @rendering = false

  def self.render_format
    @render_format
  end

  def self.rendering?
    @rendering
  end
  
  def self.rendering(format, template, &block)
    @template = template
    @render_format = format
    @rendering = true
    while record = @records_to_escape.shift
      record.kill_xss(template) if format == :html
    end
    yield
  ensure
    @render_format = nil
    @rendering = false
    @template = nil
  end
  
  def self.track(active_record)
    if rendering?
      active_record.kill_xss(@template) if @render_format == :html
    else
      @records_to_escape << active_record
    end
  end
end
