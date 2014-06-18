class AddTissues < ActiveRecord::Migration
  def self.up
    create_table :tissues do |t|
      t.string   :tsid
      t.string   :ac
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :traces, :protease_complexity_id, :integer
    add_column :traces, :substrate_complexity_id, :integer

    add_index :traces, [:protease_complexity_id]
    add_index :traces, [:substrate_complexity_id]
  end

  def self.down
    remove_column :traces, :protease_complexity_id
    remove_column :traces, :substrate_complexity_id

    drop_table :tissues

    remove_index :traces, :name => :index_traces_on_protease_complexity_id rescue ActiveRecord::StatementInvalid
    remove_index :traces, :name => :index_traces_on_substrate_complexity_id rescue ActiveRecord::StatementInvalid
  end
end
