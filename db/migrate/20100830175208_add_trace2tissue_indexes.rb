class AddTrace2tissueIndexes < ActiveRecord::Migration
  def self.up
    add_index :trace2tissues, [:trace_id]
    add_index :trace2tissues, [:tissue_id]
  end

  def self.down
    remove_index :trace2tissues, :name => :index_trace2tissues_on_trace_id rescue ActiveRecord::StatementInvalid
    remove_index :trace2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end
end
