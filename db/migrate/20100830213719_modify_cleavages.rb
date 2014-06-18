class ModifyCleavages < ActiveRecord::Migration
  def self.up
    add_column :cleavages, :cleavagesite_id, :integer

    remove_index :fragments, :name => :index_fragments_on_nending_id rescue ActiveRecord::StatementInvalid
    remove_index :fragments, :name => :index_fragments_on_cending_id rescue ActiveRecord::StatementInvalid

    add_index :cleavages, [:cleavagesite_id]
  end

  def self.down
    remove_column :cleavages, :cleavagesite_id

    add_index :fragments, [:nterm_id], :name => 'index_fragments_on_nending_id'
    add_index :fragments, [:cterm_id], :name => 'index_fragments_on_cending_id'

    remove_index :cleavages, :name => :index_cleavages_on_cleavagesite_id rescue ActiveRecord::StatementInvalid
  end
end
