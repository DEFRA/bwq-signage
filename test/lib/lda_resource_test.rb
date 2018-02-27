# frozen-string-literal: true

require 'test_helper'

# Unit tests on LdaResource
class LdaResourceTest < Minitest::Test
  TEST_BATHING_WATER_URI = 'http://environment.data.gov.uk/doc/bathing-water/ukc2106-04400.json?_view=all&_properties=samplingPoint.*'

  def setup
    VCR.use_cassette('test_bathing_water') do
      response = Net::HTTP.get_response(URI(TEST_BATHING_WATER_URI))
      json = JSON.parse(response.body)
      @resource_data = json['result']['primaryTopic']
    end
  end

  def test_lda_resource_new
    r = LdaResource.new(@resource_data)
    refute_nil r

    r = LdaResource.new(@resource_data, 'http://environment.data.gov.uk/def/bathing-water/BathingWater')
    refute_nil r

    assert_raises(RuntimeError) do
      LdaResource.new(@resource_data, 'http://environment.data.gov.uk/def/bathing-water/IDoNotExist')
    end
  end

  def test_uri_values
    assert_equal(
      ['http://data.ordnancesurvey.co.uk/id/country/england'],
      LdaResource.new(@resource_data).uri_values(:country)
    )
  end

  def test_p
    r = LdaResource.new(@resource_data)
    assert_equal(
      'http://environment.data.gov.uk/def/bathing-water/sand-sediment',
      r[:sedimentTypesPresent].uri
    )
    assert_equal 587_900.0, r['samplingPoint.northing']
    assert_equal 'Northumberland', r['district.label._value']
    assert_equal 'Northumberland', r['district']['label._value']
    assert_nil r['county.name.not_here']
  end

  def test_p_assign
    r = LdaResource.new(@resource_data)
    n = r['samplingPoint']
    assert_equal 587_900.0, n['northing']

    n['northing'] = 42
    assert_equal 42, n['northing']
  end

  def test_label_1
    r = LdaResource.new(@resource_data)
    assert_equal 'Newbiggin North', r.name
    assert_equal 'Newbiggin North', r.name(lang: 'en')
    assert_nil r.name(lang: 'klingon')
  end

  def test_label_2
    @resource_data['name'] = [
      { '_value' => 'Newbiggin North', '_lang' => 'en' },
      { '_value' => 'NKwbKggKn NKrth', '_lang' => 'klingon' }
    ]
    r = LdaResource.new(@resource_data)
    assert_equal 'Newbiggin North', r.name(lang: 'en')
    assert_equal 'NKwbKggKn NKrth', r.name(lang: 'klingon')
  end

  def test_country_label
    assert_equal 'England', LdaResource.new(@resource_data).country.label
  end

  def test_label_block
    assert_equal(
      'England, my England',
      LdaResource.new(@resource_data)['country'].label { |n| "#{n}, my #{n}" }
    )
  end

  def test_val
    r = LdaResource.new(@resource_data)
    assert_equal('Northumberland', r.val('district.label'))
  end

  def test_date
    r = LdaResource.new(test_date: { _value: '2018-02-01' })
    assert_equal(Date.new(2018, 2, 1), r.date('test_date'))
  end

  def test_empty?
    assert LdaResource.new({}).empty?
    assert LdaResource.new(nil).empty?
    refute LdaResource.new(a: { _value: 1 }).empty?
  end
end
