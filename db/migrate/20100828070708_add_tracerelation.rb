class AddTracerelation < ActiveRecord::Migration
  def self.up
    create_table :tracerelations do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :trace_id
      t.integer  :traceables_id
      t.string   :traceables_type
    end
    add_index :tracerelations, [:trace_id]
    add_index :tracerelations, [:traceables_type, :traceables_id]
  end

  def self.down
    drop_table :tracerelations
  end
end
