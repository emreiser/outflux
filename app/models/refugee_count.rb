class RefugeeCount < ActiveRecord::Base
  belongs_to :origin_id, class_name: Country, foreign_key: :origin_id
  belongs_to :destination_id, class_name: Country, foreign_key: :destination_id
end
