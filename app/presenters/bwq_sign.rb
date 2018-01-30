# frozen-string-literal: true

# Presenter for view state for bathing water signs
class BwqSign
  def initialize(params)
    @params = params
  end

  def bathing_water
    @params[:bathing_water]
  end
end
