require 'test_helper'

class Api::V1::ReportByEntryControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get api_v1_report_by_entry_show_url
    assert_response :success
  end

end
