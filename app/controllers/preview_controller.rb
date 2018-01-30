# frozen-string-literal: true

# Controller for showing a preview of the sign
class PreviewController < ApplicationController
  def show
    @view_state = BwqSign.new(
      bathing_water: bathing_water
    )
  end

  private

  def bathing_water
    bwid = params[:eubwid]
    @bw ||= api.bathing_water_by_id(bwid) if bwid
  end

  def api
    @api ||= BwqService.new
  end
end
