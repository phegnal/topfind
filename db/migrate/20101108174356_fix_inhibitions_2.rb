class FixInhibitions2 < ActiveRecord::Migration
  def self.up
    remove_column :inhibitions, :import_id
    remove_column :inhibitions, :protease_id

    remove_column :cleavages, :fragment_id

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :inhibitions, :name => :index_inhibitions_on_protease_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :inhibitions, :import_id, :integer
    add_column :inhibitions, :protease_id, :integer

    add_column :cleavages, :fragment_id, :integer

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :inhibitions, [:protease_id]

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
