class HoboMigration1 < ActiveRecord::Migration
  def self.up
    add_column :evidences, :evidencesource_id, :integer

    remove_index :evidencesources, :name => :index_evidencesources_on_evidence_id rescue ActiveRecord::StatementInvalid

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name], :unique => true

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid

    add_index :evidences, [:evidencesource_id]
  end

  def self.down
    remove_column :evidences, :evidencesource_id

    add_index :evidencesources, [:evidence_id]

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name]

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'

    remove_index :evidences, :name => :index_evidences_on_evidencesource_id rescue ActiveRecord::StatementInvalid
  end
end
