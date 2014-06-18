class Various < ActiveRecord::Migration
  def self.up
    add_column :traces, :phys_relevance, :boolean, :label => "Physiologically relevant"

    remove_column :nterms, :trace_id

    remove_column :cterms, :trace_id

    remove_index :fragments, :name => :index_fragments_on_nending_id rescue ActiveRecord::StatementInvalid
    remove_index :fragments, :name => :index_fragments_on_cending_id rescue ActiveRecord::StatementInvalid

    add_index :nterms, [:protein_id]

    add_index :cterms, [:protein_id]
  end

  def self.down
    remove_column :traces, :phys_relevance

    add_column :nterms, :trace_id, :integer

    add_column :cterms, :trace_id, :integer

    add_index :fragments, [:nterm_id], :name => 'index_fragments_on_nending_id'
    add_index :fragments, [:cterm_id], :name => 'index_fragments_on_cending_id'

    remove_index :nterms, :name => :index_nterms_on_protein_id rescue ActiveRecord::StatementInvalid

    remove_index :cterms, :name => :index_cterms_on_protein_id rescue ActiveRecord::StatementInvalid
  end
end
