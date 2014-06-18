class AddTerminimodifications < ActiveRecord::Migration
  def self.up
    create_table :terminimodifications do |t|
      t.string   :name
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :nterms, :terminimodification_id, :integer

    add_column :users, :affiliation, :string

    add_column :cterms, :terminimodification_id, :integer

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    add_index :nterms, [:terminimodification_id]

    add_index :cterms, [:terminimodification_id]

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :nterms, :terminimodification_id

    remove_column :users, :affiliation

    remove_column :cterms, :terminimodification_id

    drop_table :terminimodifications

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    remove_index :nterms, :name => :index_nterms_on_terminimodification_id rescue ActiveRecord::StatementInvalid

    remove_index :cterms, :name => :index_cterms_on_terminimodification_id rescue ActiveRecord::StatementInvalid

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
