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
end
