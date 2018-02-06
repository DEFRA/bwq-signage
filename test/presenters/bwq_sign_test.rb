# frozen-string-literal: true

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
        'show-hist': true, 'show-map': false, 'show-prf': true
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
             .must_equal('Water quality is monitored from May to November')
    end
  end

  describe '#classification_image' do
    it 'should return the parameters for the classifiation image' do
      mock_resource = mock('Resource')
      mock_resource.expects(:uri).returns('http://environment.data.gov.uk/def/bwq-cc-2015/2')
      mock_bw = mock('BathingWater1')
      mock_bw.expects(:latest_classification).returns(mock_resource)

      BwqSign.new(bathing_water: mock_bw)
             .classification_image[:alt]
             .must_equal('good water quality')
    end
  end

  describe '#show_prf?' do
    it 'should return true if the BW is in PRF, and the user ticked "yes" when asked' do
      mock_flag = mock('Value')
      mock_flag.expects(:val).returns('true')
      mock_bw = mock('BathingWater')
      mock_bw.expects(:[]).returns(mock_flag)
      params = ActionController::Parameters.new('show-prf': 'yes')

      assert BwqSign.new(bathing_water: mock_bw, params: params).show_prf?
    end

    it 'should return false if the BW is not in PRF, even if the user ticked "yes" when asked' do
      mock_flag = mock('Value')
      mock_flag.expects(:val).returns('false')
      mock_bw = mock('BathingWater')
      mock_bw.expects(:[]).returns(mock_flag)
      params = ActionController::Parameters.new('show-prf': 'yes')

      refute BwqSign.new(bathing_water: mock_bw, params: params).show_prf?
    end

    it 'should return false if the BW is in PRF, but the user ticked "no" when asked' do
      mock_flag = mock('Value')
      mock_flag.expects(:val).returns('true')
      mock_bw = mock('BathingWater')
      mock_bw.expects(:[]).returns(mock_flag)
      params = ActionController::Parameters.new('show-prf': 'no')

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
end
