class AddRepositoryToEvidences < ActiveRecord::Migration
  def self.up
    drop_table :complexities
    drop_table :fragments
    drop_table :trace2tissues
    drop_table :traceexternals
    drop_table :tracerelations
    drop_table :traces

    add_column :evidences, :repository, :text

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :evidences, :repository

    create_table "complexities", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.float    "factor"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "fragments", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "protein_id"
      t.integer  "nending_id"
      t.integer  "cending_id"
    end

    add_index "fragments", ["cending_id"], :name => "index_fragments_on_cending_id"
    add_index "fragments", ["nending_id"], :name => "index_fragments_on_nending_id"
    add_index "fragments", ["protein_id"], :name => "index_fragments_on_protein_id"

    create_table "trace2tissues", :force => true do |t|
      t.integer  "tissue_id"
      t.integer  "trace_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "trace2tissues", ["tissue_id"], :name => "index_trace2tissues_on_tissue_id"
    add_index "trace2tissues", ["trace_id"], :name => "index_trace2tissues_on_trace_id"

    create_table "traceexternals", :force => true do |t|
      t.string   "dbid"
      t.string   "dbname"
      t.string   "dburl"
      t.string   "dbdesc"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "tracerelations", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "trace_id"
      t.integer  "traceables_id"
      t.string   "traceables_type"
    end

    add_index "tracerelations", ["trace_id"], :name => "index_tracerelations_on_trace_id"
    add_index "tracerelations", ["traceables_type", "traceables_id"], :name => "index_tracerelations_on_traceables_type_and_traceables_id"

    create_table "traces", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "protease_complexity_id"
      t.integer  "substrate_complexity_id"
      t.boolean  "phys_relevance"
    end

    add_index "traces", ["protease_complexity_id"], :name => "index_traces_on_protease_complexity_id"
    add_index "traces", ["substrate_complexity_id"], :name => "index_traces_on_substrate_complexity_id"

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
