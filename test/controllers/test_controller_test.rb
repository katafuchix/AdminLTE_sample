require 'test_helper'

class TestControllerTest < ActionDispatch::IntegrationTest
  test "should get starter" do
    get test_starter_url
    assert_response :success
  end

end
