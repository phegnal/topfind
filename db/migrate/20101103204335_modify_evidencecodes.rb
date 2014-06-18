class ModifyEvidencecodes < ActiveRecord::Migration
  def self.up
    add_column :evidence2evidencecodes, :code, :integer
    remove_column :evidence2evidencecodes, :evidencecode_id

    remove_index :evidence2evidencecodes, :name => :index_evidence2evidencecodes_on_evidencecode_id rescue ActiveRecord::StatementInvalid
    add_index :evidence2evidencecodes, [:code]

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :evidence2evidencecodes, :code
    add_column :evidence2evidencecodes, :evidencecode_id, :integer

    remove_index :evidence2evidencecodes, :name => :index_evidence2evidencecodes_on_code rescue ActiveRecord::StatementInvalid
    add_index :evidence2evidencecodes, [:evidencecode_id]

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
