class AddGofunktionlinks < ActiveRecord::Migration
  def self.up
    create_table :gofunctionlinks do |t|
      t.boolean  :direct
      t.integer  :count
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :descendant_id
      t.integer  :ancestor_id
    end
    add_index :gofunctionlinks, [:ancestor_id]
    add_index :gofunctionlinks, [:descendant_id]
  end

  def self.down
    drop_table :gofunctionlinks
  end
end
