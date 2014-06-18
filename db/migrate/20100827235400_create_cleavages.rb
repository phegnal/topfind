class CreateCleavages < ActiveRecord::Migration
  def self.up
    create_table :cleavages do |t|
      t.integer  :protease_id
      t.integer  :substrate_id
      t.integer  :fragment_id
      t.integer  :primeending_id
      t.integer  :nonprimeending_id
      t.integer  :cleavagesite_id
      t.integer  :import_id
      t.integer  :pos
      t.boolean  :iscleaved
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :cleavages
  end
end
