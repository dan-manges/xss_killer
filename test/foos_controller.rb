class FoosController < ActionController::Base
  def implicit_html_render
    @foo = Foo.new :attr_to_kill_xss => params[:attr_to_kill_xss]
  end
  
  def implicit_xml_render
    @foo = Foo.new :attr_to_kill_xss => params[:attr_to_kill_xss]
  end
  
  def inline_render_param_q
    render :inline => "<%= params[:q] %>"
  end
  
  def render_other_foos_attr_to_kill_xss
    @foo = Foo.find params[:id]
    render :inline => "<%= @foo.other_foo.attr_to_kill_xss %>"
  end

  def new_person
    @person = Person.new :birthday => params[:birthday]
    render :text => ""
  end
  
  def not_presentable
    @not_presentable = Object.new
    render :text => ""
  end
  
  def foos
    foo = Foo.create!(:attr_to_kill_xss => params[:attr_to_kill_xss])
    @foos = Foo.find(:all, :conditions => {:id => foo.id})
    render :nothing => true
  end
  
  def xss_using_respond_to_block
    foo = Foo.create! :attr_to_kill_xss => params[:attr_to_kill_xss]
    @foo = Foo.find(foo.id)
    respond_to do |format|
      format.html { render :inline => "<%= debug @foo %>"}
      format.xml { render :xml => @foo.to_xml }
    end
  end
end

# Re-raise errors caught by the controller.
class FoosController; def rescue_action(e) raise e end; end

FoosController.instance_methods(false).each do |action|
  ActionController::Routing::Routes.add_route \
    "/foos/#{action}", :controller => "foos", :action => action
end
