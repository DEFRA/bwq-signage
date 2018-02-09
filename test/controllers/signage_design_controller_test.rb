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
    VCR.use_cassette('bathing_waters_api') do
      visit(root_path(design: true))
      fill_in('search', with: 'cleve')
      click_on('Search')
      page.must_have_content('Search results')
    end
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

  it 'should list results on a term that matches bathing waters and controllers' do
    VCR.use_cassette('bathing_waters_api') do
      visit(root_path(design: true, search: 'cleve'))
      page.must_have_content('Search results for "cleve"')
      find('.o-search-results__result', text: 'Clevedon Beach')
      find('.o-search-results__result', text: 'Redcar Lifeboat Station (Redcar and Cleveland)')
    end
  end

  it 'should list results for a term that matches a bathing water ID' do
    VCR.use_cassette('bathing_waters_api') do
      visit(root_path(design: true, search: 'ukk1202'))
      page.must_have_content('Search results for "ukk1202"')
      find('.o-search-results__result', text: 'Clevedon Beach')
    end
  end

  it 'should show an error message when there are no matching search results' do
    VCR.use_cassette('bathing_waters_api') do
      visit(root_path(design: true, search: 'womble'))
      page.must_have_content('Sorry, there were no matching locations for that search.')
    end
  end

  it 'should show the next step in the process when the user selects a bathing water' do
    VCR.use_cassette('bathing_water_clevedon_lookup') do
      visit(root_path(design: true, eubwid: 'ukk1202-36000'))
      page.must_have_content('Bathing water manager information for Clevedon Beach')
    end
  end

  it 'selects the name of the bathing water controller by default' do
    VCR.use_cassette('bathing_water_clevedon_lookup') do
      visit(root_path(design: true, eubwid: 'ukk1202-36000'))
      find('#bwmgr-name').value.must_equal('North Somerset')
    end
  end

  it 'shows the sign options with default values selected' do
    VCR.use_cassette('bathing_water_clevedon_lookup') do
      visit(root_path(design: true, eubwid: 'ukk1202-36000', 'bwmgr-name': 'North Somerset',
                      'bwmgr-phone': '', 'bwmgr-email': ''))
      page.must_have_content('Bathing water sign options')
      find('legend', text: 'Include pollution risk forecast information?')
      find(:radio_button, :'show-prf', checked: true).value.must_equal('yes')
    end
  end

  it 'shows the sign options with a non-default value selected' do
    VCR.use_cassette('bathing_water_clevedon_lookup') do
      visit(root_path(design: true, eubwid: 'ukk1202-36000', 'bwmgr-name': 'North Somerset',
                      'bwmgr-phone': '', 'bwmgr-email': '', 'show-prf': 'no'))
      page.must_have_content('Bathing water sign options')
      find(:radio_button, :'show-prf', checked: true).value.must_equal('no')
    end
  end

  it 'should show the preview page once the user has selected all options' do
    VCR.use_cassette('bathing_water_clevedon_lookup') do
      visit(root_path(design: true, eubwid: 'ukk1202-36000', 'bwmgr-name': 'North Somerset',
                      'bwmgr-phone': '', 'bwmgr-email': '', 'show-prf': 'no',
                      'show-hist': 'yes', 'show-logo': 'yes', 'show-map': 'yes'))
      page.must_have_content('Preview and download')
      page.must_have_selector('#development-container')
    end
  end

  it 'will not show the preview element before the options are known' do
    visit(root_path(design: true))
    page.wont_have_selector('#development-container')
  end

  it 'should show the preview page in landscape mode by default' do
    VCR.use_cassette('bathing_water_clevedon_lookup') do
      visit(root_path(design: true, eubwid: 'ukk1202-36000', 'bwmgr-name': 'North Somerset',
                      'bwmgr-phone': '', 'bwmgr-email': '', 'show-prf': 'no',
                      'show-hist': 'yes', 'show-logo': 'yes', 'show-map': 'yes'))
      page.must_have_content('change from landscape orientation')
    end
  end

  it 'should show the switch to portrait orientation on demand' do
    VCR.use_cassette('bathing_water_clevedon_lookup', record: :new_episodes) do
      visit(root_path(design: true, eubwid: 'ukk1202-36000', 'bwmgr-name': 'North Somerset',
                      'bwmgr-phone': '', 'bwmgr-email': '', 'show-prf': 'no',
                      'show-hist': 'yes', 'show-logo': 'yes', 'show-map': 'yes'))
      page.must_have_selector('.c-sign-layout--landscape')
      click_on('portrait orientation')
      page.must_have_content('change from portrait orientation')
      page.must_have_selector('.c-sign-layout--portrait')
    end
  end

  it 'should navigate back to a previous step when requested' do
    VCR.use_cassette('bathing_water_clevedon_lookup', record: :new_episodes) do
      visit(root_path(design: true, eubwid: 'ukk1202-36000', 'bwmgr-name': 'North Somerset',
                      'bwmgr-phone': '', 'bwmgr-email': '', 'show-prf': 'no',
                      'show-hist': 'yes', 'show-logo': 'yes', 'show-map': 'yes'))
      click_on('select a different bathing water')
      page.must_have_content('Which bathing water?')
    end
  end

  it 'should return to the preview after navigating back to an earlier point in the workflow' do
    VCR.use_cassette('traverse_workflow', record: :new_episodes) do
      visit(root_path(design: true, eubwid: 'ukk1202-36000', 'bwmgr-name': 'North Somerset',
                      'bwmgr-phone': '', 'bwmgr-email': '', 'show-prf': 'no',
                      'show-hist': 'yes', 'show-logo': 'yes', 'show-map': 'yes'))
      click_on('select a different bathing water')
      fill_in('search', with: 'blue anchor')
      click_on('Search')

      page.must_have_content('Search results')
      click_on('Blue Anchor West')
      page.must_have_content('Preview and download')
      find('h1', text: 'Blue Anchor West')
    end
  end
end
