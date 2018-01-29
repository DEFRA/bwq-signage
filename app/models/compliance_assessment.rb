# frozen-string-literal: true

# Model object for annual compliance assessments
class ComplianceAssessment < LdaResource
  COMPLIANCE_ENDPOINT = '/doc/bathing-water-quality/compliance-rBWD'

  COMPLIANCE_BASE = 'http://environment.data.gov.uk/def/bwq-cc-2015/'

  COMPLIANCE_CODES = {
    "#{COMPLIANCE_BASE}1" => {
      label: I18n.t('compliance_assessment.excellent'),
      description: I18n.t('compliance_assessment.excellent_description'),
      img: '3-stars.png',
      eu_img: 'baignade-3-stars.png'
    },
    "#{COMPLIANCE_BASE}2" => {
      label: I18n.t('compliance_assessment.good'),
      description: I18n.t('compliance_assessment.good_description'),
      img: '2-stars.png',
      eu_img: 'baignade-2-stars.png'
    },
    "#{COMPLIANCE_BASE}3" => {
      label: I18n.t('compliance_assessment.sufficient'),
      description: I18n.t('compliance_assessment.sufficient_description'),
      img: '1-star.png',
      eu_img: 'baignade-1-star.png'
    },
    "#{COMPLIANCE_BASE}4" => {
      label: I18n.t('compliance_assessment.poor'),
      description: I18n.t('compliance_assessment.poor_description'),
      img: 'poor-water-quality-20x16.png',
      eu_img: 'baignade-no-stars.png'
    },
    "#{COMPLIANCE_BASE}5" => {
      label: I18n.t('compliance_assessment.insufficient_samples'),
      description: I18n.t('compliance_assessment.insufficient_samples'),
      img: 'insufficient-samples-16x16.png'
    },
    "#{COMPLIANCE_BASE}6" => {
      label: I18n.t('compliance_assessment.no_classification'),
      description: I18n.t('compliance_assessment.no_classification'),
      img: 'rbwd-unclassified-16x16.png'
    },
    "#{COMPLIANCE_BASE}11" => {
      label: I18n.t('compliance_assessment.closed'),
      description: I18n.t('compliance_assessment.closed'),
      img: 'rbwd-closed-16x16.png'
    }
  }.freeze

  PROJECTED_QUALIFIER = 'http://environment.data.gov.uk/def/bathing-water-quality/projected-assessment'

  def sampling_point
    SamplingPoint.new(bwq_samplingPoint)
  end

  def self.endpoint_bw(bwid)
    "#{COMPLIANCE_ENDPOINT}/bathing-water/#{bwid}"
  end

  def year
    (sy = sampleYear) && sy.val(:ordinalYear)
  end

  def bw_uri
    bwq_bathingWater.uri
  end

  def rendering_properties
    complianceClassification&.uri &&
      COMPLIANCE_CODES[complianceClassification.uri]
  end

  def eu_img
    (rp = rendering_properties) && rp[:eu_img]
  end

  def projected?
    qualifier = assessmentQualifier
    qualifier &&
      (qualifier == PROJECTED_QUALIFIER ||
       qualifier.uri == PROJECTED_QUALIFIER)
  end

  def closed?
    complianceClassification &&
      complianceClassification.uri == "#{COMPLIANCE_BASE}11"
  end

  def poor?
    complianceClassification &&
      complianceClassification.uri == "#{COMPLIANCE_BASE}4"
  end

  def self.unclassified(year = 0)
    ComplianceAssessment.new(sampleYear: { ordinalYear: year },
                             complianceClassification: { _about: "#{COMPLIANCE_BASE}6" },
                             label: I18n.t('compliance_assessment.no_classification'))
  end
end
