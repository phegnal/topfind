class Terms < ActiveRecord::Migration
  def self.up
    remove_index :fragments, :name => :index_fragments_on_nending_id rescue ActiveRecord::StatementInvalid
    remove_index :fragments, :name => :index_fragments_on_cending_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_index :fragments, [:nterm_id], :name => 'index_fragments_on_nending_id'
    add_index :fragments, [:cterm_id], :name => 'index_fragments_on_cending_id'
  end
end
