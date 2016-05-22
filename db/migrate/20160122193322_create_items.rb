class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :item_type
      t.string :item_identifier
      t.string :item_latitude
      t.string :item_longitude
      t.string :item_location
      t.string :item_repair_time

      t.timestamps null: false
    end
  end
end
