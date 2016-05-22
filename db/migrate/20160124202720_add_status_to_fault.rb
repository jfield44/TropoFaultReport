class AddStatusToFault < ActiveRecord::Migration
  def change
    add_column :faults, :fault_status, :string
    add_column :faults, :resolved_at, :datetime
  end
end
