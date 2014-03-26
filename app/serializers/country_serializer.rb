class CountrySerializer < ActiveModel::Serializer
  attributes :code, :name, :alias
end
