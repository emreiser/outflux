class RefugeeCountsController < ApplicationController

  def index
    @refugee_counts = RefugeeCount.where(origin_id: 85).where(year: 2012)

    respond_to do |format|
      format.html
      format.json {render json: @refugee_counts}
    end
  end

end