class Import3 < ActiveRecord::Migration
  def self.up
    add_column :imports, :datatype, :string

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :imports, :datatype

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
