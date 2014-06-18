class Import6 < ActiveRecord::Migration
  def self.up
    add_column :inhibitions, :import_id, :integer

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    add_index :inhibitions, [:import_id]

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :inhibitions, :import_id

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    remove_index :inhibitions, :name => :index_inhibitions_on_import_id rescue ActiveRecord::StatementInvalid

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
