class AddEvidencecodes < ActiveRecord::Migration
  def self.up
    create_table :evidence2evidencecodes do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :evidence_id
      t.integer  :evidencecode_id
    end
    add_index :evidence2evidencecodes, [:evidence_id]
    add_index :evidence2evidencecodes, [:evidencecode_id]

    create_table :evidencecodes do |t|
      t.string   :code
      t.string   :name
      t.text     :definition
      t.datetime :created_at
      t.datetime :updated_at
    end

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    drop_table :evidence2evidencecodes
    drop_table :evidencecodes

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
