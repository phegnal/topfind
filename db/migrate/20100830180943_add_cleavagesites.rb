class AddCleavagesites < ActiveRecord::Migration
  def self.up
    create_table :cleavagesites do |t|
      t.string   :p10
      t.string   :p9
      t.string   :p8
      t.string   :p7
      t.string   :p6
      t.string   :p5
      t.string   :p4
      t.string   :p3
      t.string   :p2
      t.string   :p1
      t.string   :p1p
      t.string   :p2p
      t.string   :p3p
      t.string   :p4p
      t.string   :p5p
      t.string   :p6p
      t.string   :p7p
      t.string   :p8p
      t.string   :p9p
      t.string   :p10p
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :cleavage_id
    end
    add_index :cleavagesites, [:cleavage_id]
  end

  def self.down
    drop_table :cleavagesites
  end
end
