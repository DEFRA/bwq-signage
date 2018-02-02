# frozen-string-literal: true

require 'test_helper'

# Unit tests on bathing water search service
class BathingWaterSearchTest < ActiveSupport::TestCase
  describe 'BathingWaterSearch' do
    describe '#validate' do
      it 'should allow a search term that is letters and numbers' do
        params = ActionController::Parameters.new(search: 'foo-99').permit!
        flash = {}

        svc = BathingWaterSearch.new
        valid_params = svc.validate(params, flash)

        valid_params[:search].must_equal 'foo-99'
        flash.must_be_empty
      end

      it 'should reject an empty search term' do
        params = ActionController::Parameters.new(search: '').permit!
        flash = {}

        svc = BathingWaterSearch.new
        valid_params = svc.validate(params, flash)

        valid_params[:search].must_be_nil
        flash[:errors].must_include('Empty search input')
      end

      it 'should reject an invalid search term' do
        params = ActionController::Parameters.new(search: 'foo.*').permit!
        flash = {}

        svc = BathingWaterSearch.new
        valid_params = svc.validate(params, flash)

        valid_params[:search].must_be_nil
        flash[:errors].must_include('Non-permitted characters in search input')
      end

      it 'should find bathing waters whose names match a search term' do
        VCR.use_cassette('bathing_waters_api') do
          svc = BathingWaterSearch.new
          results = svc.search('cleve')
          results[:by_name].wont_be_empty
          results[:by_name].map(&:name).must_include('Clevedon Beach')
        end
      end

      it 'should find bathing waters whose ID matches a search term' do
        VCR.use_cassette('bathing_waters_api') do
          svc = BathingWaterSearch.new
          results = svc.search('ukc2102-03600')
          results[:by_name].must_be_empty
          results[:by_id].wont_be_empty
          results[:by_id].map(&:name).must_include('Spittal')
        end
      end

      it 'should find bathing waters whose controller name matches a search term' do
        VCR.use_cassette('bathing_waters_api') do
          svc = BathingWaterSearch.new
          results = svc.search('northumberland')
          results[:by_id].must_be_empty
          results[:by_controller].length.must_be :>=, 12
          results[:by_controller]
            .first['latestProfile.controllerName']
            .must_equal 'Northumberland'
        end
      end
    end
  end
end
