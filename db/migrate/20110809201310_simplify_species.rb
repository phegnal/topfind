class SimplifySpecies < ActiveRecord::Migration
  def self.up
    create_table :species do |t|
      t.string :name
      t.string :common_name
    end
    add_index :species, [:name], :unique => true
    add_index :species, [:common_name], :unique => true

    add_column :proteins, :species_id, :integer

    change_column :evidences, :protease_inhibitors_used, :string, :limit => 255, :null => true

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :nterm2evidences, :name => :index_nterm2evidences_on_confidence rescue ActiveRecord::StatementInvalid
    remove_index :nterm2evidences, :name => :index_nterm2evidences_on_confidence_type rescue ActiveRecord::StatementInvalid

    remove_index :cterm2evidences, :name => :index_cterm2evidences_on_confidence rescue ActiveRecord::StatementInvalid
    remove_index :cterm2evidences, :name => :index_cterm2evidences_on_confidence_type rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name], :unique => true

    add_index :proteins, [:species_id]

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :proteins, :species_id

    change_column :evidences, :protease_inhibitors_used, :string, :null => false

    drop_table :species

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :nterm2evidences, [:confidence]
    add_index :nterm2evidences, [:confidence_type]

    add_index :cterm2evidences, [:confidence]
    add_index :cterm2evidences, [:confidence_type]

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name]

    remove_index :proteins, :name => :index_proteins_on_species_id rescue ActiveRecord::StatementInvalid

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
