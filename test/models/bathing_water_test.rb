# frozen-string-literal: true

require 'test_helper'

# Unit tests on bathing water model
class BathingWaterTest < ActiveSupport::TestCase
  describe 'BathingWater' do
    describe '#api_url' do
      it 'should have a bathing water API URL based on the EUBWID' do
        bw = BathingWater.new('ukk1202-36000')
        bw.api_url.must_equal('http://environment.data.gov.uk/doc/bathing-water/ukk1202-36000.json')
      end
    end

    describe '#name' do
      it 'should return the name of the bathing water on demand' do
        bw = BathingWater.new('ukk1202-36000')
        bw.name.must_equal('Clevedon')
      end
    end
  end
end
