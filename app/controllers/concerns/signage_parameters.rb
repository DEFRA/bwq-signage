# frozen-string-literal: true

# Shared concern for extracting the allowed parameters for rendering signs
module SignageParameters
  def validate_params(additional_params)
    pp = permitted_params(additional_params)
    search.validate(pp, flash)
  end

  def permitted_params(additional_params)
    params.permit(*all_permitted_param_names(additional_params))
  end

  def all_permitted_param_names(additional_params)
    additional_params.concat(Workflow::ALL_PARAMS)
  end

  def search
    @search ||= BathingWaterSearch.new
  end

  def load_bathing_water(eubwid)
    BwqService.new.bathing_water_by_id(eubwid)
  end
end
