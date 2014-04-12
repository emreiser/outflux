class StoriesController < ApplicationController

  def index
    @country = Country.find_by(code: params[:code])

    if @country.emergency
      Rails.cache.fetch("cached_stories_#{@country.id}", expires_in: 1.days) do
        @country.getStories
      end
    end

    @stories = @country.stories.sort_by(&:created_at).reverse

    render json: @stories, meta: @country
  end

end