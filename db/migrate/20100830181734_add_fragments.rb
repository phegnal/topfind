class AddFragments < ActiveRecord::Migration
  def self.up
    create_table :fragments do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :protein_id
      t.integer  :nending_id
      t.integer  :cending_id
    end
    add_index :fragments, [:protein_id]
    add_index :fragments, [:nending_id]
    add_index :fragments, [:cending_id]
  end

  def self.down
    drop_table :fragments
  end
end
