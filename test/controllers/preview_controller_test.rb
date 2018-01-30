require "test_helper"

describe PreviewController do
  it "should get show" do
    get preview_show_url
    value(response).must_be :success?
  end

end
