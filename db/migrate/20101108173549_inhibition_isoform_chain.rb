class InhibitionIsoformChain < ActiveRecord::Migration
  def self.up
    add_column :inhibitions, :inhibited_proteaseisoform_id, :integer
    add_column :inhibitions, :inhibited_proteasechain_id, :integer
    add_column :inhibitions, :inhibitorisoform_id, :integer
    add_column :inhibitions, :inhibitorchain_id, :integer

    rename_column :cleavages, :substateisoform_id, :substrateisoform_id

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    add_index :inhibitions, [:inhibited_proteaseisoform_id]
    add_index :inhibitions, [:inhibited_proteasechain_id]
    add_index :inhibitions, [:inhibitorisoform_id]
    add_index :inhibitions, [:inhibitorchain_id]

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid
    add_index :cleavages, [:substrateisoform_id]

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :inhibitions, :inhibited_proteaseisoform_id
    remove_column :inhibitions, :inhibited_proteasechain_id
    remove_column :inhibitions, :inhibitorisoform_id
    remove_column :inhibitions, :inhibitorchain_id

    rename_column :cleavages, :substrateisoform_id, :substateisoform_id

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    remove_index :inhibitions, :name => :index_inhibitions_on_inhibited_proteaseisoform_id rescue ActiveRecord::StatementInvalid
    remove_index :inhibitions, :name => :index_inhibitions_on_inhibited_proteasechain_id rescue ActiveRecord::StatementInvalid
    remove_index :inhibitions, :name => :index_inhibitions_on_inhibitorisoform_id rescue ActiveRecord::StatementInvalid
    remove_index :inhibitions, :name => :index_inhibitions_on_inhibitorchain_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substrateisoform_id rescue ActiveRecord::StatementInvalid
    add_index :cleavages, [:substateisoform_id]

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
