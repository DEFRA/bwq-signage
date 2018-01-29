# frozen-string-literal: true

require 'test_helper'

class BwqServiceTest < Minitest::Test
  def setup
    @bws = BwqService.new
  end

  def test_all_bathing_waters
    VCR.use_cassette('test_all_bathing_waters') do
      bw = @bws.all_bathing_waters
      refute_nil bw
      assert bw.length > 400
    end
  end

  def test_bathing_waters_each
    VCR.use_cassette('test_bathing_waters_each') do
      count = 0
      seen_clevedon = false
      @bws.each_bathing_water do |bw|
        seen_clevedon ||= bw.name =~ /Clevedon/
        count += 1
      end
      assert seen_clevedon
      assert count > 400
    end
  end

  def test_bw_by_id_1
    VCR.use_cassette('test_bw_by_id_1') do
      # without pre-caching
      bw = @bws.bw_by_id('ukc2102-03600')
      refute_nil bw
      assert_equal 'Spittal', bw.name
    end
  end

  def test_bw_by_id_2
    VCR.use_cassette('test_bw_by_id_2') do
      # after caching
      @bws.all_bathing_waters
      bw = @bws.bw_by_id('ukk2204-19900')
      refute_nil bw
      assert_equal 'Kimmeridge Bay', bw.name
    end
  end

  def test_bw_by_uri_1
    VCR.use_cassette('test_bw_by_uri_1') do
      # without pre-caching
      bw = @bws.bw_by_uri('http://environment.data.gov.uk/id/bathing-water/ukc2102-03600')
      refute_nil bw
      assert_equal 'Spittal', bw.name
    end
  end

  def test_bw_by_uri_2
    VCR.use_cassette('test_bw_by_uri_2') do
      # after caching
      @bws.all_bathing_waters
      bw = @bws.bw_by_uri('http://environment.data.gov.uk/id/bathing-water/ukk2204-19900')
      refute_nil bw
      assert_equal 'Kimmeridge Bay', bw.name
    end
  end

  def test_annual_compliance
    VCR.use_cassette('test_annual_compliance') do
      acs = @bws.annual_compliance('ukc2102-03600', 3)
      assert_equal 3, acs.length
      acs.each do |ac|
        assert ac.is_a?(ComplianceAssessment)
      end
    end
  end

  def test_locales
    VCR.use_cassette('test_locales') do
      counties = @bws.locales('county')

      assert counties.size > 10
      counties.map(&:name).include?('Somerset')

      districts = @bws.locales('district')

      assert districts.size > 10
      districts.map(&:name).include?('West Somerset')
    end
  end

  def test_bws_in_county
    VCR.use_cassette('test_bws_in_county') do
      bws = @bws.bws_in_locale('county', 'Somerset')
      assert bws.size > 5
      bws.map(&:name) .include?('Porlock Weir')
    end
  end

  def test_bws_in_district
    VCR.use_cassette('test_bws_in_district') do
      bws = @bws.bws_in_locale('district', 'North Somerset')
      assert bws.size > 3
      bws.map(&:name) .include?('Clevedon')
    end
  end

  def test_bws_in_district_uri
    VCR.use_cassette('test_bws_in_district_uri') do
      bws = @bws.bws_in_locale_uri('http://statistics.data.gov.uk/id/statistical-geography/E06000052')
      assert bws.size > 30
      bws.map(&:name) .include?('Trebarwith Strand')
    end
  end
end
