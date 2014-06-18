class AddTissuesynonymes < ActiveRecord::Migration
  def self.up
    create_table :tissuesynonymes do |t|
      t.string   :sy
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :tissue_id
    end
    add_index :tissuesynonymes, [:tissue_id]
  end

  def self.down
    drop_table :tissuesynonymes
  end
end
