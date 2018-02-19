# frozen-string-literal: true

require 'test_helper'

# Unit tests on classifications sign presenter
class ClassificationsTest < ActiveSupport::TestCase
  describe 'Classifications' do
    it 'can be constructed with a bathing water' do
      bw = mock('BathingWater')
      # bw.expects  (:latest_classification_uri).returns('http://environment.data.gov.uk/def/bwq-cc-2015/1')

      Classifications.new(bw).bathing_water.must_be_same_as bw
    end

    describe 'classification image' do
      it 'should return the parameters for the classifiation image' do
        mock_resource = mock('Resource')
        mock_resource.expects(:uri).times(3).returns('http://environment.data.gov.uk/def/bwq-cc-2015/2')
        mock_bw = mock('BathingWater1')
        mock_bw.expects(:latest_classification).times(3).returns(mock_resource)

        mock_view_context = Object.new
        def mock_view_context.image_path(p)
          "path-to-#{p}"
        end

        BwqSign.new(bathing_water: mock_bw)
               .classifications.image_full[:alt]
               .must_equal('good water quality')

        BwqSign.new(bathing_water: mock_bw, view_context: mock_view_context)
               .classifications.image_compact[:src]
               .must_equal('path-to-2-stars.png')
        BwqSign.new(bathing_water: mock_bw, view_context: mock_view_context, final: true)
               .classifications
               .image_compact[:src]
               .must_equal('path-to-2-stars.svg')
      end

      it 'should return the parameters for the image for a given classification resource' do
        mock_view_context = Object.new
        def mock_view_context.image_path(p)
          "path-to-#{p}"
        end

        BwqSign.new(view_context: mock_view_context)
               .classifications
               .image_compact('http://environment.data.gov.uk/def/bwq-cc-2015/3')[:src]
               .must_equal('path-to-1-star.png')
      end

      it 'should omit the classification image for closed bathing waters' do
        resource = mock('Resource')
        resource.expects(:uri).returns('http://environment.data.gov.uk/def/bwq-cc-2015/11')

        bw = mock('BathingWater')
        bw.expects(:latest_classification).returns(resource)

        assert Classifications.new(bw).omit_classification_image?
      end

      it 'should omit the classification image for newly-designated bathing waters' do
        bw = mock('BathingWater')
        bw.expects(:latest_classification).returns(nil)

        assert Classifications.new(bw).omit_classification_image?
      end
    end
  end
end
