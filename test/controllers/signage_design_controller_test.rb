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

  it 'should have a meaningful heading' do
    visit(root_path)
    find('h1')
      .must_have_content('Create a bathing water sign')
  end

  it 'should have some instructions to the user' do
    visit(root_path)
    find('.lede')
      .text
      .wont_be_empty
  end

  it 'should have a button to start the design process' do
    visit(root_path)
    find('.button-start')
      .must_have_content('Start now')
  end
end
