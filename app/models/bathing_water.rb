# frozen-string-literal: true

# Encapsulates a single bathing water, with access to the profile data from
# the bathing water API.
class BathingWater
  attr_reader :eubwid

  def initialize(eubwid)
    @eubwid = eubwid
  end

  def api_url
    "http://environment.data.gov.uk/doc/bathing-water/#{eubwid}.json"
  end
end
