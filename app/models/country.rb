class Country < ActiveRecord::Base
  has_many :origin_ids, class_name: RefugeeCount, foreign_key: :origin_id
  has_many :destination_ids, class_name: RefugeeCount, foreign_key: :destination_id
end
