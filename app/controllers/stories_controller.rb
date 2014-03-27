class StoriesController < ApplicationController

  def index
    @country = Country.find_by(code: params[:code])

    if @country.emergency
      Rails.cache.fetch("cached_stories_#{@country.id}", expires_in: 2.days) do
        @country.getStories
      end
    end

    @stories = @country.stories.limit(4)

    render json: @stories, meta: @country
  end

end