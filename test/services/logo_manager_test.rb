# frozen-string-literal: true

require 'test_helper'

# Unit tests on Logo Manager service
class BathingWaterSearchTest < ActiveSupport::TestCase
  describe 'LogoManager' do
    describe 'constructor' do
      it 'should return nil if no bathing water mananger name is known' do
        params = ActionController::Parameters.new({})
        lm = LogoManager.new(params)
        lm.logo_name_root.must_be_nil

        params = ActionController::Parameters.new('bwmgr-name': '')
        lm = LogoManager.new(params)
        lm.logo_name_root.must_be_nil
      end

      it 'should return the normalised name of the bathing water as the image root' do
        VCR.use_cassette('aws-s3', record: :new_episodes, preserve_exact_body_bytes: true) do
          bw = mock('BathingWater')
          bw.expects(:controller_name).returns("Dun Roamin' (north)")
          api = mock('BwqService')
          api.expects(:bathing_water_by_id).with('test-bw').returns(bw)
          params = ActionController::Parameters.new(eubwid: 'test-bw')

          lm = LogoManager.new(params, api: api)
          lm.logo_name_root.must_equal 'dun-roamin-north'
        end
      end
    end
  end

  describe '#remove_existing_logo' do
    it 'should ensure that there is no logo after remove has run' do
      VCR.use_cassette('aws-s3', record: :new_episodes, preserve_exact_body_bytes: true) do
        params = ActionController::Parameters.new('bwmgr-name': 'test-bw')
        lm = LogoManager.new(params)
        lm.remove_existing_logo
        refute lm.logo_object
      end
    end
  end

  describe '#upload_and_replace' do
    it 'should allow a new logo to be uploaded' do
      VCR.use_cassette('aws-s3', record: :new_episodes, preserve_exact_body_bytes: true) do
        bw = mock('BathingWater')
        bw.expects(:controller_name).returns('test-controller')
        api = mock('BwqService')
        api.expects(:bathing_water_by_id).with('test-bw').returns(bw)
        params = ActionController::Parameters.new('eubwid': 'test-bw')

        lm = LogoManager.new(params, api: api)
        lm.remove_existing_logo
        refute lm.logo_object

        logo = file_fixture('molecule.png').open
        upload_fixture = ActionDispatch::Http::UploadedFile.new(
          tempfile: logo,
          type: 'image/png',
          filename: 'molecule.png'
        )

        lm.upload_and_replace(upload_fixture, 'png')

        lm.logo_object.key.must_equal 'bwq-signage-assets/test-controller/logo.png'
      end
    end
  end
end
