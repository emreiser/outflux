class StorySerializer < ActiveModel::Serializer
  attributes :id, :title, :image, :url, :summary, :date
  has_one :country

  def date
    object.pub_date.strftime("%b %-d, %Y")
  end
end
