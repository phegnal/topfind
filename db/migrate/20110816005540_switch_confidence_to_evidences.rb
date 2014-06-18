class SwitchConfidenceToEvidences < ActiveRecord::Migration
  def self.up
    remove_column :nterm2evidences, :confidence
    remove_column :nterm2evidences, :confidence_type

    remove_column :cterm2evidences, :confidence
    remove_column :cterm2evidences, :confidence_type

    add_column :evidences, :confidence, :float
    add_column :evidences, :confidence_type, :string, :default => "unknown"

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :nterm2evidences, :name => :index_nterm2evidences_on_confidence rescue ActiveRecord::StatementInvalid
    remove_index :nterm2evidences, :name => :index_nterm2evidences_on_confidence_type rescue ActiveRecord::StatementInvalid

    remove_index :cterm2evidences, :name => :index_cterm2evidences_on_confidence rescue ActiveRecord::StatementInvalid
    remove_index :cterm2evidences, :name => :index_cterm2evidences_on_confidence_type rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name], :unique => true

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :nterm2evidences, :confidence, :float
    add_column :nterm2evidences, :confidence_type, :string, :default => "unknown"

    add_column :cterm2evidences, :confidence, :float
    add_column :cterm2evidences, :confidence_type, :string, :default => "unknown"

    remove_column :evidences, :confidence
    remove_column :evidences, :confidence_type

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :nterm2evidences, [:confidence]
    add_index :nterm2evidences, [:confidence_type]

    add_index :cterm2evidences, [:confidence]
    add_index :cterm2evidences, [:confidence_type]

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name]

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
