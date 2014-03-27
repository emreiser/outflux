class AddUrlToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :url, :text
  end
end
