class CreateRefugeeCounts < ActiveRecord::Migration
  def change
    create_table :refugee_counts do |t|
      t.integer :year
      t.integer :origin_id
      t.integer :destination_id
      t.integer :total

      t.timestamps
    end
  end
end
