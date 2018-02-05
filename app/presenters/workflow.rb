# frozen-string-literal: true

# Encapsulates the workflow that the user moves through as they progressively
# provide the configuration choices for their BW sign
class Workflow
  STEPS = [
    { name: :landing, title: nil },
    { name: :search, title: 'bathing water name' },
    { name: :select, title: nil },
    { name: :bwmgr, title: 'bathing water manager' },
    { name: :opts, title: 'sign options' }
  ].freeze

  PRECONDITIONS = [
    { has: %i[design], missing: %i[search eubwid], name: :search },
    { has: %i[design search], missing: %i[eubwid], name: :select },
    { has: %i[design eubwid], missing: %i[bwmgr-name], name: :bwmgr },
    { has: %i[design eubwid], missing: %i[bwmgr-phone], name: :bwmgr },
    { has: %i[design eubwid], missing: %i[bwmgr-email], name: :bwmgr },
    { has: %i[design eubwid bwmgr-name], missing: %i[show-prf], name: :opts },
    { has: %i[design eubwid bwmgr-name], missing: %i[show-map], name: :opts },
    { has: %i[design eubwid bwmgr-name], missing: %i[show-hist], name: :opts },
    { has: %i[design eubwid bwmgr-name], missing: %i[show-logo], name: :opts },
    { has: %i[], missing: %i[design], name: :landing },
    { has: [], missing: [], name: :preview }
  ].freeze

  # Calculate all of the parameters that may be mentioned in the workflow
  ALL_PARAMS = PRECONDITIONS.map { |precond| [precond[:has], precond[:missing]] }
                            .flatten
                            .uniq
                            .sort
                            .freeze

  class << self
    # @return A symbol denoting the next step in the workflow
    def next_step(params)
      nominated_step?(params) ? nominated_step(params) : next_incomplete_step(params)
    end

    def nominated_step(params)
      step = params[:step] && step_name?(params[:step])
      step && step[:name]
    end
    alias nominated_step? nominated_step

    def step_name?(name)
      STEPS.find { |s| s[:name] == name.to_sym }
    end

    def next_incomplete_step(params)
      step = PRECONDITIONS.find { |precond| satisfied?(precond, params) }
      step && step[:name]
    end

    def satisfied?(precondition, params)
      all_params?(precondition[:has], params) &&
        no_params?(precondition[:missing], params)
    end

    def all_params?(required_params, params)
      required_params.reduce(true) { |acc, req_param| acc && params.key?(req_param) }
    end

    def no_params?(reject_params, params)
      reject_params.reduce(true) { |acc, req_param| acc && !params.key?(req_param) }
    end
  end
end
