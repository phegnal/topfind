class AddOwenership < ActiveRecord::Migration
  def self.up
    add_column :imports, :cterms_listed, :integer, :default => 0
    add_column :imports, :cterms_imported, :integer, :default => 0
    add_column :imports, :nterms_listed, :integer, :default => 0
    add_column :imports, :nterms_imported, :integer, :default => 0
    add_column :imports, :owner_id, :integer

    add_column :evidences, :owner_id, :integer

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    add_index :imports, [:owner_id]

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid

    add_index :evidences, [:owner_id]
  end

  def self.down
    remove_column :imports, :cterms_listed
    remove_column :imports, :cterms_imported
    remove_column :imports, :nterms_listed
    remove_column :imports, :nterms_imported
    remove_column :imports, :owner_id

    remove_column :evidences, :owner_id

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    remove_index :imports, :name => :index_imports_on_owner_id rescue ActiveRecord::StatementInvalid

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'

    remove_index :evidences, :name => :index_evidences_on_owner_id rescue ActiveRecord::StatementInvalid
  end
end
