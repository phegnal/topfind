class AddGoToTraces < ActiveRecord::Migration
  def self.up
    create_table :trace2gocomponents do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :trace_id
      t.integer  :gocomponent_id
    end
    add_index :trace2gocomponents, [:trace_id]
    add_index :trace2gocomponents, [:gocomponent_id]

    create_table :trace2gofunctions do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :trace_id
      t.integer  :gofunction_id
    end
    add_index :trace2gofunctions, [:trace_id]
    add_index :trace2gofunctions, [:gofunction_id]

    create_table :trace2goprocesses do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :trace_id
      t.integer  :goprocess_id
    end
    add_index :trace2goprocesses, [:trace_id]
    add_index :trace2goprocesses, [:goprocess_id]
  end

  def self.down
    drop_table :trace2gocomponents
    drop_table :trace2gofunctions
    drop_table :trace2goprocesses
  end
end
