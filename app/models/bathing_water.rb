# frozen-string-literal: true

# Encapsulates a single bathing water, with access to the profile data from
# the bathing water API.
class BathingWater < LdaResource
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
end
