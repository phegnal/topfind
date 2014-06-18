class DeleteIscleaved < ActiveRecord::Migration
  def self.up
    remove_column :cleavages, :iscleaved

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :cleavages, :iscleaved, :boolean

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
