# frozen-string-literal: true

require 'test_helper'

class BwqSignFinalControllerTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  describe 'BwqSignFinalController' do
    describe '#nodejs' do
      it 'should know the nodejs executable location' do
        BwqSignFinalController.new.nodejs.wont_be_empty
      end
    end

    describe '#page_url' do
      it 'should determine the correct URL for showing the sign' do
        request = ActionDispatch::Request.new({})

        controller = BwqSignFinalController.new
        controller.params = ActionController::Parameters.new(eubwid: '1234-5678')
        controller.set_request!(request)
        controller.page_url.must_equal 'http://localhost/final?eubwid=1234-5678'
      end
    end

    describe '#page_size' do
      it 'should determine the page size' do
        controller = BwqSignFinalController.new
        controller.params = ActionController::Parameters.new(page_size: 'a0')
        controller.page_size.must_equal 'a0'
      end
    end

    describe '#orientation' do
      it 'should determine the correct page orientation' do
        controller = BwqSignFinalController.new
        controller.params = ActionController::Parameters.new(page_orientation: 'landscape')
        controller.orientation.must_equal 'landscape'

        controller = BwqSignFinalController.new
        controller.params = ActionController::Parameters.new(page_orientation: 'portrait')
        controller.orientation.must_equal 'portrait'
      end

      it 'should default to landscape' do
        controller = BwqSignFinalController.new
        controller.params = ActionController::Parameters.new
        controller.orientation.must_equal 'landscape'
      end
    end

    it 'should show the final sign' do
      VCR.use_cassette('final_layout_1') do
        visit(final_path(design: true, eubwid: 'ukk1202-36000', 'bwmgr-name': 'North Somerset',
                         'bwmgr-phone': '', 'bwmgr-email': '', 'show-prf': 'no',
                         'show-hist': 'yes', 'show-logo': 'yes', 'show-map': 'yes'))
        page.must_have_content 'Clevedon Beach'
        page.wont_have_content 'Preview'
      end
    end
  end
end
