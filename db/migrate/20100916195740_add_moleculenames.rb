class AddMoleculenames < ActiveRecord::Migration
  def self.up
    create_table :moleculenames do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :molecule_id
    end
    add_index :moleculenames, [:molecule_id]
  end

  def self.down
    drop_table :moleculenames
  end
end
