class Import7 < ActiveRecord::Migration
  def self.up
    add_column :nterms, :import_id, :integer

    add_column :cterms, :import_id, :integer

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    add_index :nterms, [:import_id]

    add_index :cterms, [:import_id]

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :nterms, :import_id

    remove_column :cterms, :import_id

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    remove_index :nterms, :name => :index_nterms_on_import_id rescue ActiveRecord::StatementInvalid

    remove_index :cterms, :name => :index_cterms_on_import_id rescue ActiveRecord::StatementInvalid

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
