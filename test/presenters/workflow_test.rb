# frozen-string-literal: true

# Unit tests on Workflow presenter
# rubocop:disable Metrics/LineLength
class WorkflowTest < ActiveSupport::TestCase
  describe 'Workflow' do
    describe '#nominated_step' do
      it 'should recognise a nominated step' do
        Workflow.nominated_step(step: 'landing').must_equal :landing
        Workflow.nominated_step(step: :landing).must_equal :landing
      end

      it 'should reject a nominated step with an incorrect name' do
        refute Workflow.nominated_step(step: 'stairs')
      end

      it 'should not recognise a step with an incorrect key' do
        refute Workflow.nominated_step(pest: 'landing')
      end
    end

    describe '#next_incomplete_step' do
      it 'should select the landing step if given no information' do
        Workflow.next_incomplete_step({}).must_equal :landing
      end

      it 'should select the search step when the design workflow starts' do
        Workflow.next_incomplete_step(design: true).must_equal :search
      end

      it 'should select the select step when a search term is given' do
        Workflow.next_incomplete_step(design: true, search: 'foo').must_equal :select
      end

      it 'should select the sign-design step when the bw is selected' do
        Workflow.next_incomplete_step(design: true, eubwid: '123').must_equal :signplus
      end

      it 'should select the options step when the bw is selected' do
        Workflow.next_incomplete_step(design: true, eubwid: '123', 'sign-plus': 'complete').must_equal :opts
      end

      it 'should select the options step unless all options info is known' do
        Workflow.next_incomplete_step(design: true, eubwid: '123', 'sign-plus': 'complete', 'show-hist': 'no')
                .must_equal :opts
        Workflow.next_incomplete_step(design: true, eubwid: '123', 'sign-plus': 'complete',
                                      'show-hist': 'no', 'show-map': 'no')
                .must_equal :opts
      end

      it 'should select preview when all information is complete' do
        Workflow.next_incomplete_step(design: true, eubwid: '123', 'sign-plus': 'complete', 'bwmgr-email': 'foo',
                                      'bwmgr-name': 'bar', 'bwmgr-phone': '',
                                      'show-hist': true, 'show-map': false,
                                      'show-logo': false, 'bwmgr-logo': 'test.png')
                .must_equal :preview
      end
    end

    describe 'ALL_PARAMS' do
      it 'should calculate a list of all of the parameters used in the workflow' do
        Workflow::ALL_PARAMS.must_include :search
        Workflow::ALL_PARAMS.must_include :'bwmgr-name'
        Workflow::ALL_PARAMS.length.must_be :>=, 9
        Workflow::ALL_PARAMS.wont_include :foobar
      end
    end
  end
end
# rubocop:enable Metrics/LineLength
