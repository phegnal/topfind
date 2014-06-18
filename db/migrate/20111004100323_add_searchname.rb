class AddSearchname < ActiveRecord::Migration
  def self.up
    create_table :searchnames do |t|
      t.integer   :id
      t.integer  :protein_id
      t.string   :name
    end
    add_index :searchnames, [:protein_id, :name]
  end

  def self.down

    drop_table :searchnames
    remove_index :name
    remove_index :protein_id
  end
end
