class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.text :title
      t.text :url
      t.text :image
      t.text :summary
      t.datetime :pub_date
      t.references :country, index: true

      t.timestamps
    end
  end

end
