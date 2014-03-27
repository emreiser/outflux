class AddEmergencyToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :emergency, :boolean
    add_column :countries, :url, :text
  end
end
