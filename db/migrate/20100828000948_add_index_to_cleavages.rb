class AddIndexToCleavages < ActiveRecord::Migration
  def self.up
    add_index :cleavages, [:protease_id]
    add_index :cleavages, [:substrate_id]
  end

  def self.down
    remove_index :cleavages, :name => :index_cleavages_on_protease_id rescue ActiveRecord::StatementInvalid
    remove_index :cleavages, :name => :index_cleavages_on_substrate_id rescue ActiveRecord::StatementInvalid
  end
end
