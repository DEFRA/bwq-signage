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
        params = ActionController::Parameters.new('bwmgr-name': "Dun Roamin' (north) ")
        lm = LogoManager.new(params)
        lm.logo_name_root.must_equal 'dun-roamin-north'
      end
    end
  end

  describe '#remove_existing_logo' do
    it 'should ensure that there is no logo after remove has run' do
      VCR.use_cassette('aws-s3', record: :new_episodes) do
        params = ActionController::Parameters.new('bwmgr-name': 'test-bw')
        lm = LogoManager.new(params)
        lm.remove_existing_logo
        refute lm.logo_object
      end
    end
  end

  describe '#upload_and_replace' do
    it 'should allow a new logo to be uploaded' do
      VCR.use_cassette('aws-s3', record: :new_episodes) do
        params = ActionController::Parameters.new('bwmgr-name': 'test-bw')
        lm = LogoManager.new(params)
        lm.remove_existing_logo
        refute lm.logo_object

        logo = file_fixture('molecule.png').open
        upload_fixture = ActionDispatch::Http::UploadedFile.new(
          tempfile: logo,
          type: 'image/png',
          filename: 'molecule.png'
        )

        puts 'before upload'
        lm.upload_and_replace(upload_fixture, 'png')

        puts 'after upload'
        lm.logo_object.key.must_equal 'bwq-signage-assets/test-bw/logo.png'
        puts 'done'
      end
    end
  end
end
