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
end
