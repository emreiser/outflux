class RefugeeCount < ActiveRecord::Base
  belongs_to :origin, class_name: Country
  belongs_to :destination, class_name: Country

  validates :year, uniqueness: {scope: [:destination_id, :origin_id]}
end
