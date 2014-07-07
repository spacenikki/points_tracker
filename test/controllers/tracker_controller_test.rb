require 'test_helper'

class TrackerControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get add_ff" do
    get :add_ff
    assert_response :success
  end

end
