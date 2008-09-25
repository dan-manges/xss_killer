require File.dirname(__FILE__) + "/test_helper"

class ActionControllerExtensionTest < Test::Unit::TestCase

  def setup
    @controller = FoosController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  test "escapes html if format is html" do
    @request.env["HTTP_ACCEPT"] = "text/html"
    get :xss_using_respond_to_block, :attr_to_kill_xss => "<dan>"
    assert_equal "&lt;dan&gt;", @response.body
  end
  
  test "does not escacpe html if format is xml" do
    @request.env["HTTP_ACCEPT"] = "text/xml"
    get :xss_using_respond_to_block, :attr_to_kill_xss => "<dan>"
    assert_equal "<dan>", assigns(:foo).attr_to_kill_xss
  end
  
  test "escapes html if using implicit html template" do
    get :implicit_html_render, :attr_to_kill_xss => "<dan>"
    assert_equal "<div>&lt;dan&gt;</div>\n", @response.body
  end
  
  test "does not escape html if format is implicit xml" do
    get :implicit_xml_render, :attr_to_kill_xss => "<dan>"
    assert_equal "application/xml", @response.content_type
    assert_equal "<dan>", assigns(:foo).attr_to_kill_xss
  end
  
  test "records in an array get html escaped" do
    get :foos, :attr_to_kill_xss => "<dan>"
    assert_equal "&lt;dan&gt;", @response.body
  end
  
  test "records loaded after render is called get escaped" do
    foo = Foo.create! :other_foo => Foo.create!(:attr_to_kill_xss => "<dan>")
    get :render_other_foos_attr_to_kill_xss, :id => foo.id
    assert_equal "&lt;dan&gt;", @response.body
  end

end
