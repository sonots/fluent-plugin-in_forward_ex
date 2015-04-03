require_relative 'helper'
require 'fluent/test'
require 'fluent/plugin/in_forward_ex'

def unused_port
  s = TCPServer.open(0)
  port = s.addr[1]
  s.close
  port
end

class ForwardInputExTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)
  end

  TMP_DIR = File.expand_path(File.dirname(__FILE__) + "/../tmp/in_forward")
  PORT = unused_port
  CONFIG = %[
    port #{PORT}
    bind 127.0.0.1
  ]

  def create_driver(conf=CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::ForwardExInput).configure(conf)
  end

  def stop_file
    "#{TMP_DIR}/stop"
  end

  def test_stop_file_configure
    d = create_driver(CONFIG + %[stop_file #{stop_file}\nstop_file_interval 1])
    assert_equal "#{TMP_DIR}/stop", d.instance.stop_file
    assert_equal 1, d.instance.stop_file_interval
  end

  sub_test_case "test stop" do
    def test_stop_file_bootup
      # stop file does not exist on bootup
      d = create_driver(CONFIG + %[stop_file #{stop_file}])
      d.instance.start
      assert_equal true, d.instance.active?
      d.instance.shutdown

      # stop file exists on bootup
      d = create_driver(CONFIG + %[stop_file #{stop_file}])
      File.open(stop_file, "w").close
      d.instance.start
      assert_not_equal true, d.instance.active?
      d.instance.shutdown
    end

    # appear => disappear => appear
    def test_stop_file_interval
      File.unlink(stop_file) rescue nil
      d = create_driver(CONFIG + %[stop_file #{stop_file}])
      d.instance.start

      # appear
      File.open(stop_file, "w").close
      d.instance.on_stop_file_timer
      assert_not_equal true, d.instance.active?

      # disappear
      File.unlink(stop_file) rescue nil
      d.instance.on_stop_file_timer
      assert_equal true, d.instance.active?

      # appear
      File.open(stop_file, "w").close
      d.instance.on_stop_file_timer
      assert_not_equal true, d.instance.active?
    end
  end
end
