class AddStatusToProteinAndIsoform < ActiveRecord::Migration
  def self.up
    add_column :proteins, :status, :string, :default => "unknown"

    remove_column :chains, :chain_id

    add_column :isoforms, :status, :string, :default => "unknown"

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :chains, :name => :index_chains_on_chain_id rescue ActiveRecord::StatementInvalid

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :proteins, :status

    add_column :chains, :chain_id, :integer

    remove_column :isoforms, :status

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    add_index :chains, [:chain_id]

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
