class RefugeeCountsController < ApplicationController

  def index
    codes = ["1", "47", "65", "44", "105", "146", "200", "189", "211", "144"]

    @countries = codes.map do |code|
      Country.find_by(code: code)
    end

    @countries.sort_by!(&:name)

    if params[:code]
      @country = Country.find_by(code: params[:code])
      origin_id = @country.id

      @refugee_counts = Rails.cache.fetch("refugee_count_#{@country.id}", expires_in: 30.days) do
        RefugeeCount.where(origin_id: origin_id).includes(:destination)
      end

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