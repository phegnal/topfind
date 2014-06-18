class ReplaceFragmentsWithChains < ActiveRecord::Migration
  def self.up
    drop_table :fragments

    create_table :chains do |t|
      t.string   :name
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :protein_id
      t.integer  :cterm_id
      t.integer  :nterm_id
    end
    add_index :chains, [:protein_id]
    add_index :chains, [:cterm_id]
    add_index :chains, [:nterm_id]
  end

  def self.down
    create_table "fragments", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "protein_id"
      t.integer  "nterm_id"
      t.integer  "cterm_id"
    end

    add_index "fragments", ["cterm_id"], :name => "index_fragments_on_cending_id"
    add_index "fragments", ["cterm_id"], :name => "index_fragments_on_cterm_id"
    add_index "fragments", ["nterm_id"], :name => "index_fragments_on_nending_id"
    add_index "fragments", ["nterm_id"], :name => "index_fragments_on_nterm_id"
    add_index "fragments", ["protein_id"], :name => "index_fragments_on_protein_id"

    drop_table :chains
  end
end
