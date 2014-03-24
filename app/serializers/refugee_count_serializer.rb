class RefugeeCountSerializer < ActiveModel::Serializer
  attributes :id, :year, :total, :destination_id

  has_one :destination
end
