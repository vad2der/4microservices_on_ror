require 'test_helper'

class Api::V1::InputControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_v1_input_create_url
    assert_response :success
  end

end
