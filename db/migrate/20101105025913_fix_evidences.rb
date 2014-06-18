class FixEvidences < ActiveRecord::Migration
  def self.up
    rename_column :evidencerelations, :traceables_type, :traceable_type
    rename_column :evidencerelations, :traceables_id, :traceable_id

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid
    add_index :evidencerelations, [:traceable_type, :traceable_id]

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    rename_column :evidencerelations, :traceable_type, :traceables_type
    rename_column :evidencerelations, :traceable_id, :traceables_id

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceable_type_and_traceable_id rescue ActiveRecord::StatementInvalid
    add_index :evidencerelations, [:traceables_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
