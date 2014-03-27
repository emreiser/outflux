class AddEmergencyToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :emergency, :boolean
  end
end
