# frozen-string-literal: true

require 'test_helper'

describe PreviewController do
  it 'should show the preview page without error' do
    VCR.use_cassette('preview_page_test_1') do
      get preview_url(eubwid: 'ukk1202-36000')
      value(response).must_be :success?
    end
  end
end
