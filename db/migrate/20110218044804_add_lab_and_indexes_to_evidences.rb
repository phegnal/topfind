class AddLabAndIndexesToEvidences < ActiveRecord::Migration
  def self.up
    add_column :evidences, :lab, :string

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid

    add_index :evidences, [:name]
    add_index :evidences, [:method]
    add_index :evidences, [:lab]
    add_index :evidences, [:phys_relevance]
    add_index :evidences, [:directness]
  end

  def self.down
    remove_column :evidences, :lab

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'

    remove_index :evidences, :name => :index_evidences_on_name rescue ActiveRecord::StatementInvalid
    remove_index :evidences, :name => :index_evidences_on_method rescue ActiveRecord::StatementInvalid
    remove_index :evidences, :name => :index_evidences_on_lab rescue ActiveRecord::StatementInvalid
    remove_index :evidences, :name => :index_evidences_on_phys_relevance rescue ActiveRecord::StatementInvalid
    remove_index :evidences, :name => :index_evidences_on_directness rescue ActiveRecord::StatementInvalid
  end
end
