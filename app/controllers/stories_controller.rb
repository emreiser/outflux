class StoriesController < ApplicationController

  def index
    @country = Country.find_by(code: params[:code])
    @stories = @country.stories.limit(4)

    render json: @stories, meta: @country
  end

end