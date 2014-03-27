class StorySerializer < ActiveModel::Serializer
  attributes :id, :title, :image, :url, :summary

  has_one :country
end
