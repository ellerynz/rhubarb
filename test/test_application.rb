require_relative "test_helper"

class TestController < Rhubarb::Controller

  def index
    "Hello world!"
  end

end

class TestApp < Rhubarb::Application

  def get_controller_and_action(env)
    [TestController, "index"]
  end
end

class RhubarbAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    TestApp.new
  end

  def test_request
    get "/test/index"

    assert last_response.ok?
    body = last_response.body
    assert body["Hello world!"]
  end

  def test_array
    assert_equal 3, [1,1,1].sum
  end

  def test_to_underscore
    assert_equal "my/sweet_controller", Rhubarb.to_underscore("My::SweetController")
    assert_equal "sweet_controller", Rhubarb.to_underscore("SweetController")
    assert_equal "a7_d", Rhubarb.to_underscore("a7D")
  end

  def test_instance_variables_available_in_view

  end

end
