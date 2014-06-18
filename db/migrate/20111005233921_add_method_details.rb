class AddMethodDetails < ActiveRecord::Migration
  def self.up
    change_column :proteins, :meropsfamily, :string, :limit => 255, :null => true

    add_column :evidences, :method_system, :string, :default => "unknown"
    add_column :evidences, :method_protease_source, :string, :default => "unknown"
    add_column :evidences, :methodology, :string, :default => "unknown"

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name], :unique => true

    remove_index :proteins, :name => :meropsfamily rescue ActiveRecord::StatementInvalid
    add_index :proteins, [:meropsfamily]

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid

    add_index :evidences, [:method_system]
    add_index :evidences, [:method_protease_source]
    add_index :evidences, [:methodology]
  end

  def self.down
    change_column :proteins, :meropsfamily, :string, :null => false

    remove_column :evidences, :method_system
    remove_column :evidences, :method_protease_source
    remove_column :evidences, :methodology

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name]

    remove_index :proteins, :name => :index_proteins_on_meropsfamily rescue ActiveRecord::StatementInvalid
    add_index :proteins, [:meropsfamily], :name => 'meropsfamily'

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'

    remove_index :evidences, :name => :index_evidences_on_method_system rescue ActiveRecord::StatementInvalid
    remove_index :evidences, :name => :index_evidences_on_method_protease_source rescue ActiveRecord::StatementInvalid
    remove_index :evidences, :name => :index_evidences_on_methodology rescue ActiveRecord::StatementInvalid
  end
end
