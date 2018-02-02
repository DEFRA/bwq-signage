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

  it 'should navigate to the first step in the workflow' do
    visit(root_path)
    click_on(class: 'button-start')
    page.must_have_current_path(root_path(design: true))
  end

  it 'should allow the user to enter a search term' do
    visit(root_path(design: true))
    fill_in('search', with: 'cleve')
    click_on('Search')
    page.must_have_content('Search results')
  end

  it 'should reject an empty search term' do
    visit(root_path(design: true))
    click_on('Search')
    page.wont_have_content('Search results')
    find('.error-summary').must_have_content('Empty search input')
  end

  it 'should reject a search term with punctuation' do
    visit(root_path(design: true))
    fill_in('search', with: '; drop table')
    click_on('Search')
    page.wont_have_content('Search results')
    find('.error-summary').must_have_content('Non-permitted characters in search input')
  end
end
