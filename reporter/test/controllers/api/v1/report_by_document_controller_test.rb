require 'test_helper'

class Api::V1::ReportByDocumentControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get api_v1_report_by_document_show_url
    assert_response :success
  end

end
