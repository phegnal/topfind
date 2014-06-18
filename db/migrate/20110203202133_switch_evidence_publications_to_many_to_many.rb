class SwitchEvidencePublicationsToManyToMany < ActiveRecord::Migration
  def self.up
    create_table :evidence2publications do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :evidence_id
      t.integer  :publication_id
    end
    add_index :evidence2publications, [:evidence_id]
    add_index :evidence2publications, [:publication_id]

    remove_column :publications, :evidence_id

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :publications, :name => :index_publications_on_evidence_id rescue ActiveRecord::StatementInvalid

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :publications, :evidence_id, :integer

    drop_table :evidence2publications

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    add_index :publications, [:evidence_id]

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
