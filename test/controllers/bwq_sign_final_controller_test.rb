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
        controller.page_url.must_equal 'http://localhost:3000/final?eubwid=1234-5678'
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

    it 'should normalize the bathing water name for inclusion in the file name' do
      bathing_water = mock('BathingWater')
      bathing_water.expects(:name).returns("foo bar'd (north)")
      bwq_service = mock('BwqService')
      bwq_service.expects(:bathing_water_by_id).with('1234-5678').returns(bathing_water)

      controller = BwqSignFinalController.new
      controller.api = bwq_service
      controller.params = ActionController::Parameters.new(eubwid: '1234-5678')

      controller.bathing_water_name_normalized.must_equal 'foo-bard-north'
    end

    it 'should create a descriptive file name for the download file' do
      bathing_water = mock('BathingWater')
      bathing_water.expects(:name).returns("foo bar'd (north)")
      bwq_service = mock('BwqService')
      bwq_service.expects(:bathing_water_by_id).with('1234-5678').returns(bathing_water)

      controller = BwqSignFinalController.new
      controller.api = bwq_service
      controller.params = ActionController::Parameters.new(eubwid: '1234-5678')

      controller.pdf_file_name.must_equal 'bwq-sign-foo-bard-north-a4-landscape.pdf'
    end

    it 'should download a pdf file' do
      # don't currently have a good way to do this in CI
      unless ENV['TRAVIS']
        VCR.use_cassette('final_layout_2', record: :new_episodes) do
          driver = Capybara.current_driver
          begin
            Capybara.current_driver = :rack_test

            visit(download_path(eubwid: 'ukk1202-36000', 'bwmgr-name': 'North Somerset',
                                'bwmgr-phone': '', 'bwmgr-email': '', 'show-prf': 'yes',
                                'show-hist': 'yes', 'show-logo': 'yes', 'show-map': 'yes',
                                page_size: 'a4', page_orientation: 'landscape',
                                port: 3000))

            page.response_headers['Content-Type'].must_equal('application/pdf')
            header = page.response_headers['Content-Disposition']
            header.must_match(/^attachment/)
            header.must_match(/filename=\"bwq-sign-clevedon-beach-a4-landscape.pdf\"$/)
          ensure
            Capybara.current_driver = driver
          end
        end
      end
    end
  end
end
