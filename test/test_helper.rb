# rails
require "rubygems"
gem "rails", "2.1.0"
require "active_record"
require "action_controller"
require "action_controller/test_process"

# xss_killer
$LOAD_PATH << File.dirname(__FILE__) + "/lib"
require "xss_killer"

# test/unit
require "test/unit"
Test::Unit::TestCase.class_eval do
  def self.test(method, &block)
    define_method "test_#{method}".gsub(/\W/,"_"), &block
  end
end

# test setup
ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"
ActiveRecord::Schema.define :version => 1 do
  create_table "foos" do |t|
    t.string "attr_to_kill_xss"
    t.string "attr_to_allow_injection"
    t.string "attr_to_sanitize"
    t.integer "attr_integer"
    t.datetime "attr_datetime"
    t.integer "other_foo_id"
  end
end

require File.dirname(__FILE__) + "/foos_controller"
ActionController::Base.view_paths = ["#{File.dirname(__FILE__)}/views"]

class Foo < ActiveRecord::Base
  belongs_to :other_foo, :class_name => "Foo", :foreign_key => "other_foo_id"
  kill_xss :allow_injection => ["attr_to_allow_injection"],
           :sanitize => ["attr_to_sanitize"]
end
