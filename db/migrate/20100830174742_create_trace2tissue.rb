class CreateTrace2tissue < ActiveRecord::Migration
  def self.up
    create_table :trace2tissues do |t|
      t.integer  :tissue_id
      t.integer  :trace_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :trace2tissues
  end
end
