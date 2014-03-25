class RefugeeCountsController < ApplicationController

  def index
    binding.pry

    if params[:code]
      @country = Country.find_by(code: params[:code])
      origin_id = @country.id

      @refugee_counts = RefugeeCount.where(origin_id: origin_id).includes(:destination)
      respond_to do |format|
        format.html
        format.json {render json: @refugee_counts, meta: @country}
      end
    else
      respond_to do |format|
        format.html
      end
    end

  end

end