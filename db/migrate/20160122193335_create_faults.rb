class CreateFaults < ActiveRecord::Migration
  def change
    create_table :faults do |t|
      t.string :fault_type
      t.string :fault_description
      t.string :fault_reported_by
      t.references :item, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
