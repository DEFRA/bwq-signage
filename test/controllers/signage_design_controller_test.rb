# frozen-string-literal: true

require 'test_helper'

class SignageDesignControllerTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  it 'should set the proposition title correctly' do
    visit(root_path)
    find('.header-proposition')
      .must_have_content('Create a bathing water sign')
  end
end
