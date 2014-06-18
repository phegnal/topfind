class ImproveTerminusmodifications < ActiveRecord::Migration
  def self.up
    add_column :terminusmodifications, :nterm, :boolean, :default => false
    add_column :terminusmodifications, :cterm, :boolean, :default => false
    add_column :terminusmodifications, :subcess, :string
    add_column :terminusmodifications, :psimodid, :string
    add_column :terminusmodifications, :display, :boolean, :default => true
    add_column :terminusmodifications, :kw_id, :integer

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name], :unique => true

    add_index :terminusmodifications, [:kw_id]

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :terminusmodifications, :nterm
    remove_column :terminusmodifications, :cterm
    remove_column :terminusmodifications, :subcess
    remove_column :terminusmodifications, :psimodid
    remove_column :terminusmodifications, :display
    remove_column :terminusmodifications, :kw_id

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name]

    remove_index :terminusmodifications, :name => :index_terminusmodifications_on_kw_id rescue ActiveRecord::StatementInvalid

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
