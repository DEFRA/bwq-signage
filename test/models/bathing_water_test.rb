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

    describe '#season_dates' do
      it 'should return the start end end of the monitoring season' do
        bw = BathingWater.new(bw_fixture)
        bw.season_dates[0].must_be_kind_of(Date)
        bw.season_dates[1].must_be_kind_of(Date)
        bw.season_dates[0] < bw.season_dates[1]
      end
    end

    describe '#latest_classification' do
      it 'should return the latest classification as an LDA resource' do
        BathingWater.new(bw_fixture)
                    .latest_classification
                    .uri
                    .must_match(/^http:/)
      end
    end

    describe '#pollution_source_statements' do
      it 'should extract the pollution sources and algae statements from the profile' do
        stmts = BathingWater.new(bw_fixture).pollution_source_statements
        stmts.length.must_equal 2
        stmts[0].must_match(/Bathing water quality may reduce during or after periods of heavy/)
        stmts[1].must_match(/This bathing water beach often has patches of seaweed/)
      end
    end
  end
end
