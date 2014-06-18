class BigCleanupTracesEvidencesPublications < ActiveRecord::Migration
  def self.up
    create_table :evidencesources do |t|
      t.string   :dbid
      t.string   :dbname
      t.string   :dburl
      t.string   :dbdesc
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :evidence_id
    end
    add_index :evidencesources, [:evidence_id]

    create_table :evidencerelations do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :evidence_id
      t.integer  :traceables_id
      t.string   :traceables_type
    end
    add_index :evidencerelations, [:evidence_id]
    add_index :evidencerelations, [:traceables_type, :traceables_id]

    create_table :evidence2gocomponents do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :evidence_id
      t.integer  :gocomponent_id
    end
    add_index :evidence2gocomponents, [:evidence_id]
    add_index :evidence2gocomponents, [:gocomponent_id]

    create_table :publications do |t|
      t.integer  :pmid
      t.string   :title
      t.text     :authors
      t.text     :abstract
      t.string   :ref
      t.string   :doi
      t.string   :url
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :evidence_id
    end
    add_index :publications, [:evidence_id]

    add_column :evidence2tissues, :evidence_id, :integer

    change_column :evidences, :phys_relevance, :string, :default => "unknown", :limit => 255
    change_column :evidences, :directness, :string, :default => "unknown", :limit => 255

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
    add_index :evidence2tissues, [:evidence_id]
  end

  def self.down
    remove_column :evidence2tissues, :evidence_id

    change_column :evidences, :phys_relevance, :string, :default => "--- :unknown\n"
    change_column :evidences, :directness, :string, :default => "--- :unknown\n"

    drop_table :evidencesources
    drop_table :evidencerelations
    drop_table :evidence2gocomponents
    drop_table :publications

    remove_index :evidence2tissues, :name => :index_evidence2tissues_on_evidence_id rescue ActiveRecord::StatementInvalid
    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
