class AddMoreProteinIndexes < ActiveRecord::Migration
  def self.up
    create_table :proteins_oss, :id => false do |t|
      t.integer :os_id
      t.integer :protein_id
    end

    create_table :proteins_oxs, :id => false do |t|
      t.integer :ox_id
      t.integer :protein_id
    end
  end

  def self.down
    drop_table :proteins_oss
    drop_table :proteins_oxs
  end
end
