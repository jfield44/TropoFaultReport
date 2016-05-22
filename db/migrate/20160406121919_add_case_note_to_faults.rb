class AddCaseNoteToFaults < ActiveRecord::Migration
  def change
    add_column :faults, :case_note, :string
  end
end
