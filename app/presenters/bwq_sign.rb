# frozen-string-literal: true

# Presenter for view state for bathing water signs
class BwqSign
  attr_reader :options

  def initialize(options)
    @options = options
  end

  def bathing_water
    options[:bathing_water]
  end

  def params
    options[:params]
  end

  def next_workflow_step
    Workflow.next_step(params)
  end

  def search_term
    params[:search]
  end

  def search_results
    @search_results ||= options[:search].search(search_term)
  end

  def show_preview?
    next_workflow_step == :preview
  end
end
