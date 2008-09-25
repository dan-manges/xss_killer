# rails
require "rubygems"
gem "rails", ENV['RAILS_VERSION'] || "> 0"
require "rails/version"
puts "==== Testing with Rails #{Rails::VERSION::STRING} ===="
require "active_record"
require "action_controller"
require "action_view"
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
silence_stream(STDOUT) do
  ActiveRecord::Schema.define :version => 1 do
    create_table "foos" do |t|
      t.string "attr_to_kill_xss"
      t.string "attr_to_allow_injection"
      t.string "attr_to_sanitize"
      t.integer "attr_integer"
      t.datetime "attr_datetime"
      t.integer "other_foo_id"
      t.text "attr_text"
    end
    create_table "bars" do |t|
      t.string "name"
    end
  end
end

require File.dirname(__FILE__) + "/foos_controller"
ActionController::Base.view_paths = ["#{File.dirname(__FILE__)}/views"]

class Foo < ActiveRecord::Base
  belongs_to :other_foo, :class_name => "Foo", :foreign_key => "other_foo_id"
  kills_xss :allow_injection => ["attr_to_allow_injection"],
           :sanitize => ["attr_to_sanitize"]
end

class Bar < ActiveRecord::Base
end
