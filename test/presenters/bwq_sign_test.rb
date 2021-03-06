# frozen-string-literal: true

require 'test_helper'

# Unit tests on BWQ sign presenter
class BwqSignTest < ActiveSupport::TestCase
  describe 'BwqSign' do
    describe 'setup' do
      it 'should allow access to the state of the presenter' do
        mock_bw = { bw: :mock }
        mock_params = { foo: :bar }

        bwq_sign = BwqSign.new(bathing_water: mock_bw, params: mock_params)
        bwq_sign.bathing_water.must_equal mock_bw
        bwq_sign.params.must_equal mock_params
      end
    end
  end

  describe 'workflow' do
    describe '#next_workflow_step' do
      it 'should calculate the next workflow step given the parameters' do
        params = ActionController::Parameters.new(design: true).permit!
        bwq_sign = BwqSign.new(params: params)

        bwq_sign.next_workflow_step.must_equal :search
      end
    end
  end

  describe 'search' do
    it 'should return the search term from the params' do
      params = ActionController::Parameters.new(search: 'kermit').permit!
      bwq_sign = BwqSign.new(params: params)
      bwq_sign.search_term.must_equal('kermit')
    end

    it 'should delegate searching to the search service' do
      search_service = mock('search_service')
      search_service.expects(:search).with('kermit').returns(['miss piggy'])

      params = ActionController::Parameters.new(search: 'kermit').permit!
      bwq_sign = BwqSign.new(params: params, search: search_service)
      bwq_sign.search_results.must_equal(['miss piggy'])
    end
  end

  describe 'preview' do
    it 'should return true when the preview is visible' do
      # not all page params are present
      base = {
        design: true, eubwid: '123', 'bwmgr-email': 'foo',
        'bwmgr-name': 'bar', 'bwmgr-phone': '',
        'show-hist': true, 'show-map': false, 'show-prf': true,
        'bwmgr-logo': 'test.png', 'sign-plus': 'complete'
      }
      refute BwqSign.new(params: ActionController::Parameters.new(base).permit!).show_preview?

      # add the missing param
      base[:'show-logo'] = true
      assert BwqSign.new(params: ActionController::Parameters.new(base).permit!).show_preview?
    end
  end

  describe 'page orientation' do
    it 'should return the default page orientation if not specified' do
      po = BwqSign.new(params: ActionController::Parameters.new).page_orientation
      po[:current].must_equal('landscape')
      po[:alt].must_equal('portrait')
      po[:current_icon].wont_be_nil
      po[:alt_icon].wont_be_nil
    end

    it 'should return the page orientation if not specified' do
      params = ActionController::Parameters.new(page_orientation: 'portrait').permit!
      po = BwqSign.new(params: params).page_orientation
      po[:current].must_equal('portrait')
      po[:alt].must_equal('landscape')
      po[:current_icon].wont_be_nil
      po[:alt_icon].wont_be_nil
    end
  end

  describe 'page size' do
    it 'should return false if the page is not a3' do
      params = ActionController::Parameters.new({}).permit!
      refute BwqSign.new(params: params).a3_page?
    end

    it 'should return true for a3 pages' do
      params = ActionController::Parameters.new(page_size: 'a3').permit!
      assert BwqSign.new(params: params).a3_page?
    end
  end

  describe '#with_query_params' do
    it 'should merge the given params with the current query params' do
      params = ActionController::Parameters.new(page_orientation: 'portrait', design: true).permit!
      BwqSign.new(params: params)
             .with_query_params(page_orientation: 'landscape', foo: 'bar')
             .must_equal('page_orientation' => 'landscape', 'design' => true, 'foo' => 'bar')
    end
  end

  describe '#monitoring_statement' do
    it 'should return the statement of when the season is open' do
      mock_bw = mock('BathingWater')
      mock_bw.expects(:season_dates).returns([Date.new(2018, 5, 1), Date.new(2018, 11, 30)])
      BwqSign.new(bathing_water: mock_bw)
             .monitoring_statement
             .must_equal('Water quality is monitored from May&nbsp;to&nbsp;November by the Environment&nbsp;Agency') # rubocop:disable Metrics/LineLength
    end
  end

  describe '#show_prf?' do
    it 'should return true if the BW is in PRF' do
      mock_flag = mock('Value')
      mock_flag.expects(:val).returns('true')
      mock_bw = mock('BathingWater')
      mock_bw.expects(:[]).returns(mock_flag)
      params = ActionController::Parameters.new

      assert BwqSign.new(bathing_water: mock_bw, params: params).show_prf?
    end

    it 'should return false if the BW is not in PRF' do
      mock_flag = mock('Value')
      mock_flag.expects(:val).returns('false')
      mock_bw = mock('BathingWater')
      mock_bw.expects(:[]).returns(mock_flag)
      params = ActionController::Parameters.new

      refute BwqSign.new(bathing_water: mock_bw, params: params).show_prf?
    end
  end

  describe '#qr_code' do
    it 'should return the correct QR code for the bathing water profile' do
      mock_bw = mock('BathingWater')
      mock_bw.expects(:eubwid).returns('paddington-bear')
      BwqSign.new(bathing_water: mock_bw)
             .qr_code_url
             .must_equal('http://environment.data.gov.uk/bwq/profiles/images/qr/paddington-bear-100x100.png')
    end
  end

  describe '#show_map?' do
    it 'should return true if the user wants to include the map' do
      assert BwqSign.new(params: ActionController::Parameters.new('show-map': 'yes')).show_map?
      refute BwqSign.new(params: ActionController::Parameters.new('show-map': 'no')).show_map?
    end
  end

  describe '#show_history?' do
    it 'should return true if the user wants to include the map' do
      assert BwqSign.new(params: ActionController::Parameters.new('show-hist': 'yes')).show_history?
      refute BwqSign.new(params: ActionController::Parameters.new('show-hist': 'no')).show_history?
    end
  end

  describe '#show_logo?' do
    it 'should return true if the user wants to include the EA logo' do
      assert BwqSign.new(params: ActionController::Parameters.new('show-logo': 'yes')).show_logo?
      refute BwqSign.new(params: ActionController::Parameters.new('show-logo': 'no')).show_logo?
    end
  end

  describe '#bw_manager' do
    it 'should collate the properties relating to the bathing water manager' do
      params = {
        'bwmgr-name': 'nnnn',
        'bwmgr-phone': '1234-5678',
        'bwmgr-email': 'foo@bar.com'
      }

      collated = BwqSign.new(params: ActionController::Parameters.new(params)).bw_manager
      collated[:name].must_equal 'nnnn'
      collated[:phone].must_equal '1234-5678'
      collated[:email].must_equal 'foo@bar.com'
    end
  end

  describe '#hidden_params' do
    it 'should return an array of the params to be hidden in a form' do
      BwqSign.new(params:
                  ActionController::Parameters.new('show-hist': 'yes', design: true).permit!)
             .hidden_params([:design])
             .must_equal [['show-hist', 'yes']]
    end
  end

  describe '#final?' do
    it 'should return a flag when showing the final view' do
      refute BwqSign.new({}).final?
      assert BwqSign.new(final: true).final?
    end
  end

  describe 'logo url' do
    it 'should determine the logo URL if the key is given' do
      assert BwqSign.new(params:
                         ActionController::Parameters.new('bwmgr-logo': 'foo/bar.png').permit!)
                    .show_bwmgr_logo?
      refute BwqSign.new(params:
                         ActionController::Parameters.new('bwmgr-logo': 'none').permit!)
                    .show_bwmgr_logo?
    end

    it 'should correctly determine the S3 URL' do
      BwqSign.new(params:
                  ActionController::Parameters.new('bwmgr-logo': 'foo/bar.png').permit!)
             .bwmgr_logo_url
             .must_match(%r{^https://environment-open-data.*aws.*foo/bar.png$})
    end
  end

  describe '#next_by_controller' do
    it 'should precess through the bws for a controller' do
      VCR.use_cassette('precess-controller', record: :new_episodes) do
        bw = BwqService.new.bathing_water_by_id('ukk1202-36000')
        bw0 = BwqSign.new(bathing_water: bw).next_by_bw_controller
        bw0.name.must_equal('Weston Main')

        bw1 = BwqSign.new(bathing_water: bw0).next_by_bw_controller
        bw1.name.must_equal('Weston-super-Mare Sand Bay')

        bw2 = BwqSign.new(bathing_water: bw1).next_by_bw_controller
        bw2.name.must_equal('Weston-super-Mare Uphill Slipway')

        bw3 = BwqSign.new(bathing_water: bw2).next_by_bw_controller
        bw3.name.must_equal('Clevedon Beach')
      end
    end

    it 'should prevent precessing for controllers with only one bathing water' do
      VCR.use_cassette('precess-controller', record: :new_episodes) do
        # BW ukk1302-11760 is the Cotswold Country Park
        bw = BwqService.new.bathing_water_by_id('ukk1302-11760')
        BwqSign.new(bathing_water: bw).next_by_bw_controller.must_be_nil
      end
    end
  end

  describe '#logo_manager' do
    it 'should return the logo manager instance' do
      params = ActionController::Parameters.new({}).permit!
      bwq_sign = BwqSign.new(params: params)
      logo_mgr = bwq_sign.logo_manager
      logo_mgr.wont_be_nil
      bwq_sign.logo_manager.must_be_same_as(logo_mgr)
    end
  end

  describe '#pollution_sources_css_clas' do
    it 'should return the correct class for bw with a short name and PRF' do
      value = mock('Value')
      value.expects(:val).returns('true')
      bw = mock('BathingWater')
      bw.expects(:'[]').with('latestProfile.pollutionRiskForecasting').returns(value)
      bw.expects(:long_pollution_description?).twice.returns(false, false)

      params = ActionController::Parameters.new({}).permit!
      bwq_sign = BwqSign.new(params: params, bathing_water: bw)

      bwq_sign.pollution_sources_css_class.must_equal('o-content-unit__1-2')
    end

    it 'should return the correct class for bw with a short name and no PRF' do
      value = mock('Value')
      value.expects(:val).returns('false')
      bw = mock('BathingWater')
      bw.expects(:'[]').with('latestProfile.pollutionRiskForecasting').returns(value)
      bw.expects(:long_pollution_description?).twice.returns(false, false)

      params = ActionController::Parameters.new({}).permit!
      bwq_sign = BwqSign.new(params: params, bathing_water: bw)

      bwq_sign.pollution_sources_css_class.must_equal('o-content-unit__1-1c')
    end

    it 'should return the correct class for bw with a long name and PRF' do
      value = mock('Value')
      value.expects(:val).returns('true')
      bw = mock('BathingWater')
      bw.expects(:'[]').with('latestProfile.pollutionRiskForecasting').returns(value)
      bw.expects(:long_pollution_description?).twice.returns(true, false)

      params = ActionController::Parameters.new({}).permit!
      bwq_sign = BwqSign.new(params: params, bathing_water: bw)

      bwq_sign.pollution_sources_css_class.must_equal('o-content-unit__1-2 u-long-text')
    end
  end

  describe '#title_css_class' do
    it 'should return the correct class for bw with a short title' do
      bw = mock('BathingWater')
      bw.expects(:name).returns('not a long name')

      params = ActionController::Parameters.new({}).permit!
      bwq_sign = BwqSign.new(params: params, bathing_water: bw)

      bwq_sign.title_css_class.must_equal('')
    end

    it 'should return the correct class for bw with a long title' do
      bw = mock('BathingWater')
      bw.expects(:name).returns('a long name indeed, possibly too long')

      params = ActionController::Parameters.new({}).permit!
      bwq_sign = BwqSign.new(params: params, bathing_water: bw)

      bwq_sign.title_css_class.must_equal('u-long-title')
    end
  end
end
