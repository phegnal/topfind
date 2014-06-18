class AddMeropstoprotein < ActiveRecord::Migration
  def self.up
    add_column :proteins, :meropsfamily, :string
    add_column :proteins, :meropssubfamily, :string
    add_column :proteins, :meropscode, :string

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name], :unique => true

    add_index :proteins, [:chromosome]
    add_index :proteins, [:band]
    add_index :proteins, [:meropsfamily]
    add_index :proteins, [:meropssubfamily]
    add_index :proteins, [:meropscode]

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :proteins, :meropsfamily
    remove_column :proteins, :meropssubfamily
    remove_column :proteins, :meropscode

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name]

    remove_index :proteins, :name => :index_proteins_on_chromosome rescue ActiveRecord::StatementInvalid
    remove_index :proteins, :name => :index_proteins_on_band rescue ActiveRecord::StatementInvalid
    remove_index :proteins, :name => :index_proteins_on_meropsfamily rescue ActiveRecord::StatementInvalid
    remove_index :proteins, :name => :index_proteins_on_meropssubfamily rescue ActiveRecord::StatementInvalid
    remove_index :proteins, :name => :index_proteins_on_meropscode rescue ActiveRecord::StatementInvalid

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
