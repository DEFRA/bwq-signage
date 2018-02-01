# frozen-string-literal: true

# Facade-pattern class to place a convenience wrapper around a JSON structure
# denoting a resource returned from an LDA endpoint
module LdaResource # rubocop:disable Metrics/ModuleLength
  attr_reader :resource

  def initialize(resource, expected_type = nil)
    @resource = as_resource(resource)
    assert_has_type(expected_type) if expected_type && !types.empty?
  end

  def types
    uri_values(:type)
  end

  def uri_values(p)
    array_of(p).keep_if { |x| x } .map do |v|
      v.respond_to?(:uri) ? v.uri : v
    end
  end

  def assert_has_type(t)
    return if types.include?(t)
    raise "Resource does not have expected type. Expected #{t.inspect}, found #{types.inspect}"
  end

  def [](path)
    path_first(path)
  end

  # Return the first value along the given path for this object
  def path_first(path)
    v = path.to_s.split('.').reduce(@resource) do |memo, pe|
      path_single_descendant(memo[pe]) if memo&.key?(pe)
    end

    v.is_a?(Hash) ? LdaResource.new(v) : v
  end

  def path_single_descendant(v)
    v.is_a?(Array) ? v.first : v
  end

  # Return all values along the given path for this object
  def path_all(path)
    v = [@resource]
    path.to_s.split('.').each do |pe|
      v = (v.map { |vv| vv.is_a?(Hash) && vv[pe] }).flatten.keep_if { |x| x }
    end

    v.map { |vv| vv.is_a?(Hash) ? LdaResource.new(vv) : vv }
  end

  def []=(key, value)
    @resource[key] = value
  end

  def uri(p = nil)
    v = p ? self[p] : self
    v.is_a?(Hash) || v.is_a?(LdaResource) ? v['_about'] : v
  end

  def val(p = nil)
    v = p ? self[p] : self
    v.is_a?(Hash) || v.is_a?(LdaResource) ? v['_value'] : v
  end

  def date(p = nil)
    d = val(p)
    d && Time.parse(d)
  end

  def label(options = {}, &block)
    l = lang_select(path_all(:label), options)
    block ? yield(l) : l
  end

  def name(options = {}, &block)
    n = lang_select(path_all(:name), options)
    block ? yield(n) : n
  end

  def lang(options = {})
    options[:lang]
  end

  def default_lang
    'en'
  end

  def method_missing(m, *_args) # rubocop:disable Style/MethodMissing
    self[m]
  end

  def identity_value
    self[:_about] || self[:_value] || resource
  end

  def eql?(other)
    identity_value.eql?(other.identity_value) if other.respond_to?(:identity_value)
  end

  def hash
    identity_value.hash
  end

  def empty?
    !@resource || @resource.empty?
  end

  private

  def array_of(pred)
    v = path_all(pred)
    v.is_a?(Array) ? v : [v]
  end

  def indifferent_hash(h)
    h.is_a?(HashWithIndifferentAccess) ? h : HashWithIndifferentAccess.new(h)
  end

  def lang_select(values, options)
    preferred_lang = lang(options)
    term = { _value: nil, _lang: nil }

    values.each do |v|
      term = if v.is_a?(String)
               { _value: v, _lang: :default }
             else
               keep_better_option(v, term, preferred_lang)
             end
    end

    term[:_value]
  end

  def keep_better_option(v, term, preferred_lang)
    if uses_preferred_lang?(v, preferred_lang) ||
       uses_default_lang?(v, preferred_lang) ||
       no_preference?(preferred_lang) ||
       no_selection_yet?(term, preferred_lang)
      v
    else
      term
    end
  end

  def uses_preferred_lang?(v, preferred_lang)
    preferred_lang && v[:_lang] == preferred_lang
  end

  def uses_default_lang?(v, preferred_lang)
    !preferred_lang && v[:_lang] == default_lang
  end

  def no_preference?(preferred_lang)
    !preferred_lang
  end

  def no_selection_yet?(term, preferred_lang)
    !term[:value] && !preferred_lang
  end

  def as_resource(r)
    if r.is_a?(LdaResource)
      r.resource
    elsif r.is_a?(String)
      indifferent_hash(_about: r)
    else
      indifferent_hash(r)
    end
  end
end
