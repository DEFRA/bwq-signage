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

    describe '#next_workflow_step' do
      it 'should calculate the next workflow step given the parameters' do
        params = ActionController::Parameters.new(design: true).permit!
        bwq_sign = BwqSign.new(params: params)

        bwq_sign.next_workflow_step.must_equal :search
      end
    end
  end
end
