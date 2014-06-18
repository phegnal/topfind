class Modifications2 < ActiveRecord::Migration
  def self.up
    create_table :terminusmodifications do |t|
      t.string   :name
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :nterms, :terminusmodification_id, :integer
    remove_column :nterms, :modification

    add_column :cterms, :terminusmodification_id, :integer
    remove_column :cterms, :modification

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    add_index :nterms, [:terminusmodification_id]

    add_index :cterms, [:terminusmodification_id]

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :nterms, :terminusmodification_id
    add_column :nterms, :modification, :string

    remove_column :cterms, :terminusmodification_id
    add_column :cterms, :modification, :string

    drop_table :terminusmodifications

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    remove_index :nterms, :name => :index_nterms_on_terminusmodification_id rescue ActiveRecord::StatementInvalid

    remove_index :cterms, :name => :index_cterms_on_terminusmodification_id rescue ActiveRecord::StatementInvalid

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
