class Story < ActiveRecord::Base
  belongs_to :country
  validates :title, uniqueness: true


end
