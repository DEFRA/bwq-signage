# frozen-string-literal: true

# Presenter for view state for bathing water signs
class BwqSign
  def initialize(options)
    @options = options
  end

  def bathing_water
    @options[:bathing_water]
  end

  def params
    @options[:params]
  end

  def next_workflow_step
    Workflow.next_step(params)
  end
end
