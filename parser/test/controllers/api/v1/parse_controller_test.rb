require 'test_helper'

class Api::V1::ParseControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_v1_parse_create_url
    assert_response :success
  end

end
