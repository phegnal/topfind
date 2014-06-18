class RefactorPolymorphicEvidences2Hasmany < ActiveRecord::Migration
  def self.up
    create_table :inhibition2evidences do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :evidence_id
      t.integer  :inhibition_id
    end
    add_index :inhibition2evidences, [:evidence_id]
    add_index :inhibition2evidences, [:inhibition_id]

    create_table :chain2evidences do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :evidence_id
      t.integer  :chain_id
    end
    add_index :chain2evidences, [:evidence_id]
    add_index :chain2evidences, [:chain_id]

    create_table :cleavage2evidences do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :evidence_id
      t.integer  :cleavage_id
    end
    add_index :cleavage2evidences, [:evidence_id]
    add_index :cleavage2evidences, [:cleavage_id]

    create_table :nterm2evidences do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :evidence_id
      t.integer  :nterm_id
    end
    add_index :nterm2evidences, [:evidence_id]
    add_index :nterm2evidences, [:nterm_id]

    create_table :cterm2evidences do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :evidence_id
      t.integer  :cterm_id
    end
    add_index :cterm2evidences, [:evidence_id]
    add_index :cterm2evidences, [:cterm_id]

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    drop_table :inhibition2evidences
    drop_table :chain2evidences
    drop_table :cleavage2evidences
    drop_table :nterm2evidences
    drop_table :cterm2evidences

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
