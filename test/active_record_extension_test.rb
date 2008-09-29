require File.dirname(__FILE__) + "/test_helper"

class ActiveRecordExtensionTest < Test::Unit::TestCase
  test "setting which attributes are escaped" do
    foo = Foo.new :attr_to_allow_injection => "<js>", :attr_to_kill_xss => "<js>"
    XssKiller.rendering :html, ActionView::Base.new do
      assert_equal "<js>", foo.attr_to_allow_injection
      assert_equal "&lt;js&gt;", foo.attr_to_kill_xss
    end
  end

  test "escaping works when inheriting" do
    foo = SubFoo.new :attr_to_allow_injection => "<js>", :attr_to_kill_xss => "<js>"
    XssKiller.rendering :html, ActionView::Base.new do
      assert_equal "<js>", foo.attr_to_allow_injection
      assert_equal "&lt;js&gt;", foo.attr_to_kill_xss
    end
  end

  test "derived classes can kill xss even if base class does not" do
    base = Bar.new :name => "<js>"
    derived = SubBar.new :name => "<js>"
    XssKiller.rendering :html, ActionView::Base.new do
      assert_equal "<js>", base.name
      assert_equal "&lt;js&gt;", derived.name
    end
  end
  
  test "models not annotated with kills_xss to do not escape html" do
    bar = Bar.new :name => "<js>"
    XssKiller.rendering :html, ActionView::Base.new do
      assert_equal "<js>", bar.name
    end
  end
  
  test "using sanitize" do
    link = "<p><a href=\"http://www.google.com\">google</a></p>"
    foo = Foo.new :attr_to_sanitize => "<a href='http://www.google.com'>google</a>"
    XssKiller.rendering :html, ActionView::Base.new do
      assert_equal link, foo.attr_to_sanitize
    end

    js = "<script></script>"
    foo = Foo.new :attr_to_sanitize => js
    XssKiller.rendering :html, ActionView::Base.new do
      assert_equal "<p></p>", foo.attr_to_sanitize
    end
  end
  
  test "if using sanitize it also uses simple_format" do
    formatted = "<p><a href=\"http://www.google.com\">google\n<br />line2</a></p>"
    foo = Foo.new :attr_to_sanitize => "<a href='http://www.google.com'>google\nline2</a>"
    XssKiller.rendering :html, ActionView::Base.new do
      assert_equal formatted, foo.attr_to_sanitize
    end
  end
end
