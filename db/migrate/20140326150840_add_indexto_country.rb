class AddIndextoCountry < ActiveRecord::Migration
  def change
    add_index :countries, :code
  end

  def change
    add_index :refugee_counts, :origin_id
  end
end
