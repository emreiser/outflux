class RefugeeCountsController < ApplicationController

  def index

    if params[:id]
      country_id = params[:id].to_i
      @refugee_counts = RefugeeCount.where(origin_id: country_id).where(year: 2012).includes(:destination_id)
      respond_to do |format|
        format.html
        format.json {render json: @refugee_counts}
      end
    else
      respond_to do |format|
        format.html
      end
    end

  end

end