# frozen-string-literal: true

# Encapsulates a single bathing water, with access to the profile data from
# the bathing water API.
class BathingWater < LdaResource
  MAX_HISTORY_YEARS = 3

  RDFS_CLASS = 'http://environment.data.gov.uk/def/bathing-water/BathingWater'

  def self.endpoint_all
    '/doc/bathing-water'
  end

  def self.endpoint_bw(bwid)
    "#{BathingWater.endpoint_all}/#{bwid}"
  end

  def eubwid
    self['eubwidNotation']
  end

  def controller_name
    self['latestProfile.controllerName']
  end

  def closed?
    latest_compliance_assessment.closed?
  end

  def season_dates
    [
      Date.parse(val('latestProfile.seasonStartDate')),
      Date.parse(val('latestProfile.seasonFinishDate'))
    ]
  end

  def latest_compliance_assessment
    ComplianceAssessment.new(self['latestComplianceAssessment'])
  end

  def latest_classification
    self['latestComplianceAssessment.complianceClassification']
  end

  def pollution_source_statements
    stmts = []

    sps_stmt = self['latestProfile.signPollutionSourcesStatement']
    stmts << sps_stmt.val if sps_stmt

    alg_stmt = self['latestProfile.signAlgaeStatement']
    stmts << alg_stmt.val if alg_stmt

    stmts
  end

  def long_pollution_description?(limit)
    pollution_source_statements.map(&:length).sum >= limit
  end

  def prf_statement
    self['latestProfile.signPRFSummary'].val
  end

  def classification_history
    api.annual_compliance(eubwid, MAX_HISTORY_YEARS)
  end

  def to_json
    JSON.generate(
      lat: self['samplingPoint.lat'],
      long: self['samplingPoint.long']
    )
  end

  private

  def api
    @api ||= BwqService.new
  end
end
