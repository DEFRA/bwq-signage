# frozen-string-literal: true

require 'test_helper'

# Unit tests on bathing water model
class BathingWaterTest < ActiveSupport::TestCase
  describe 'BathingWater' do
    let(:bw_fixture) do
      file_content = file_fixture('bathing-water.json').read
      JSON.parse(file_content, symbolize_names: true)[:result][:primaryTopic]
    end

    describe '#eubwid' do
      it 'should have a bathing water EUBWID' do
        begin
          bw = BathingWater.new(bw_fixture)
          bw.eubwid.must_equal('ukk1202-36000')
        end
      end
    end

    describe '#name' do
      it 'should return the name of the bathing water' do
        bw = BathingWater.new(bw_fixture)
        bw.name.must_equal('Clevedon Beach')
      end
    end

    describe '#controller_name' do
      it 'should return the name of the bw controller' do
        bw = BathingWater.new(bw_fixture)
        bw.controller_name.must_equal('North Somerset')
      end
    end
  end
end
