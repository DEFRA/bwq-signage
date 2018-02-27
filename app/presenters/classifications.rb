# frozen-string-literal: true

CLASSIFICATION_IMAGES = {
  'http://environment.data.gov.uk/def/bwq-cc-2015/1' =>
      { src: 'baignade-3-stars', alt: 'excellent water quality' },
  'http://environment.data.gov.uk/def/bwq-cc-2015/2' =>
      { src: 'baignade-2-stars', alt: 'good water quality' },
  'http://environment.data.gov.uk/def/bwq-cc-2015/3' =>
      { src: 'baignade-1-star', alt: 'sufficient water quality' },
  'http://environment.data.gov.uk/def/bwq-cc-2015/4' =>
      { src: 'baignade-no-stars-no-bathing', alt: 'poor water quality' }
}.freeze

# Presenter for bathing water classifications in different contexts
class Classifications
  attr_reader :bathing_water
  attr_reader :view_context
  attr_reader :final
  alias :'final?' final

  def initialize(bathing_water, view_context = nil, final = false)
    @bathing_water = bathing_water
    @final = final
    @view_context = view_context
  end

  def classification_uri(uri = nil)
    uri || bathing_water.latest_classification&.uri
  end

  def omit_classification_image?(uri = nil)
    class_uri = classification_uri(uri)
    !class_uri || !CLASSIFICATION_IMAGES.key?(class_uri)
  end

  def image_full(uri = nil)
    image_root = CLASSIFICATION_IMAGES[classification_uri(uri)]

    {
      alt: image_root[:alt],
      src: view_context.image_path("#{image_root[:src]}.svg")
    }
  end

  def image_compact(uri = nil)
    image_root = CLASSIFICATION_IMAGES[classification_uri(uri)]
    svg_image = "#{image_root[:src].gsub(/baignade-/, '')}.#{final? ? 'svg' : 'png'}"

    {
      alt: image_root[:alt],
      src: view_context.image_path(svg_image)
    }
  end

  # How would we present a classification in the history summary?
  def show_compact(classification)
    curi = classification.complianceClassification.uri
    image_description = image_compact(curi) if CLASSIFICATION_IMAGES.key?(curi)
    image = image_description &&
            "<img src='#{image_description[:src]}' alt='#{image_description[:alt]}'></img>"
    "#{classification.year} #{image} #{classification.complianceClassification.name}"
  end
end
