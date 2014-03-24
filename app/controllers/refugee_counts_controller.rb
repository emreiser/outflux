class RefugeeCountsController < ApplicationController

  def index

    if params[:id]
      country_id = params[:id].to_i
      @refugee_counts = RefugeeCount.where(origin_id: country_id).includes(:destination)
      respond_to do |format|
        format.html
        format.json {render json: @refugee_counts, root: false}
      end
    else
      respond_to do |format|
        format.html
      end
    end

  end

end