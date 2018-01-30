# frozen-string-literal: true

# Encapsulates the service interface with the remote BWQ linked data API endpoint
class BwqService < LdaApi
  ENDPOINTS = {
    production: 'http://localhost',
    test: 'http://ea-rbwd-staging.epimorphics.net',
    development: 'http://ea-rbwd-staging.epimorphics.net'
  }.freeze

  DETAILED_BW_PROPERTIES = %w[
    latestSampleAssessment.sampleDateTime.inXSDDateTime
    latestSampleAssessment.sampleYear.ordinalYear
    latestSampleAssessment.escherichiaColiCount.*
    latestSampleAssessment.intestinalEnterococciCount.*
    latestProfile.webResImage
    latestProfile.pollutionRiskForecasting
    latestProfile.seasonStartDate
    latestProfile.seasonFinishDate
    latestComplianceAssessment.sampleYear.ordinalYear
    latestRiskPrediction.*
  ].join(',')

  ENGLAND_URI = 'http://data.ordnancesurvey.co.uk/id/country/england'

  def environment
    Rails.env.to_sym
  end

  def url_root
    ENDPOINTS[environment]
  end

  def bws_by_uri
    @bws_by_uri ||= {}
  end

  def bws_by_id
    @bws_by_id ||= {}
  end

  # Return a list of all known bathing waters. List is cached for future re-use
  def all_bathing_waters(country = ENGLAND_URI)
    if bws_by_uri.empty?
      options = { _pageSize: 600 }
      options[:country] = country unless country == :all

      bws = api_get_resources(BathingWater.endpoint_all, ALL_PAGES, BathingWater, options)
      bws.each do |bw|
        bws_by_uri[bw.uri] = bw
        bws_by_id[bw.id] = bw
      end
    end

    bws_by_uri.values
  end

  # Perform block for each bathing water in the list of all bathing waters
  def each_bathing_water(&block)
    all_bathing_waters.each(&block)
  end

  # Return the description of a bathing water, given its eubwid
  def bathing_water_by_id(bwid)
    unless bws_by_id[bwid]
      options = { _properties: DETAILED_BW_PROPERTIES }
      bws_by_id[bwid] = api_get_resources(BathingWater.endpoint_bw(bwid), :item,
                                          BathingWater, options)
    end

    bws_by_id[bwid]
  end

  # Return the description of a bathing water, given its uri
  def bw_by_uri(uri)
    unless bws_by_uri[uri]
      options = { _properties: DETAILED_BW_PROPERTIES }
      url = relative_url(uri)
      bws_by_uri[uri] = api_get_resources(url, :item, BathingWater, options)
    end

    bws_by_uri[uri]
  end

  # Return the latest N annual compliance results, newest first
  def annual_compliance(bwid, n)
    options = { _pageSize: n, _sort: '-sampleYear.ordinalYear' }
    api_get_resources(ComplianceAssessment.endpoint_bw(bwid), nil, ComplianceAssessment, options)
  end

  # Return an array of the named locales of the given type (county or district)
  def locales(locale_type)
    locs = Set.new

    each_bathing_water do |bw|
      l = bw[locale_type]
      locs << l if l.is_a?(LdaResource)
    end

    locs.to_a.sort_by(&:label)
  end

  # Return an array of the bathing waters in a given named locale
  def bws_in_locale(locale_type, locale_name)
    options = { _pageSize: 600,
                "#{locale_type}.name" => locale_name,
                _properties: DETAILED_BW_PROPERTIES }
    api_get_resources(BathingWater.endpoint_all, LdaApi::ALL_PAGES, BathingWater, options)
  end

  # Return an array of the bathing waters in a given locale URI
  def bws_in_locale_uri(locale_uri, locale_type = 'district')
    options = { _pageSize: 600,
                locale_type => locale_uri,
                _properties: DETAILED_BW_PROPERTIES }
    api_get_resources(BathingWater.endpoint_all, LdaApi::ALL_PAGES, BathingWater, options)
  end

  # Return the bathing water sites in JSON format
  def bathing_water_names_json
    locations_as_json(all_bathing_waters.map { |bw| { label: bw.name, uri: bw.uri } })
  end

  # Return the district names in JSON format
  def locale_names_json
    districts = locales(:district).map { |d| { label: d.name, uri: d.uri, type: 'district' } }
    counties = locales(:county).map { |d| { label: d.name, uri: d.uri, type: 'county' } }

    locations_as_json(districts.concat(counties))
  end

  def locations_as_json(locations)
    JSON.generate(locations.sort_by { |a| a[:label] })
  end
end
