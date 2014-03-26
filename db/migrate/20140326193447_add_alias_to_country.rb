class AddAliasToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :alias, :text
  end
end
