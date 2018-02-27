# frozen-string-literal: true

require 'test_helper'

# Unit tests on bathing water model
class ComplianceAssessmentTest < ActiveSupport::TestCase
  describe 'ComplianceAssessment' do
    let(:ca_fixture) do
      file_content = file_fixture('compliance-assessment.json').read
      JSON.parse(file_content, symbolize_names: true)[:result][:primaryTopic]
    end

    let(:ca) do
      ComplianceAssessment.new(ca_fixture)
    end

    describe '#bw_uri' do
      it 'should return the URI of the bathing water' do
        ca.bw_uri.must_equal('http://environment.data.gov.uk/id/bathing-water/ukk1202-36000')
      end
    end

    describe '#year' do
      it 'should return the year' do
        ca.year.must_equal(2016)
      end
    end

    describe '#rendering_properties' do
      it 'should describe relevant rendering properties' do
        ca.rendering_properties[:label].must_equal 'good'
      end
    end

    describe '#eu_img' do
      it 'should return the EU bw image root' do
        ca.eu_img.must_equal('baignade-2-stars.png')
      end
    end

    describe '#projected?' do
      it 'should return true if a projected classification' do
        refute ca.projected?
      end
    end

    describe '#poor?' do
      it 'should return true if a poor classification' do
        refute ca.poor?
      end
    end

    describe '#closed?' do
      it 'should return true if a closed classification' do
        refute ca.closed?
      end
    end
  end
end
