class AddDocumentations < ActiveRecord::Migration
  def self.up
    create_table :documentations do |t|
      t.string   :name
      t.string   :title
      t.text     :long
      t.text     :short
      t.string   :category
      t.integer  :position, :default => 0
      t.boolean  :show, :default => false
      t.datetime :created_at
      t.datetime :updated_at
    end

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name], :unique => true

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    drop_table :documentations

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name]

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
