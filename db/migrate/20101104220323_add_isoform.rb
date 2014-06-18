class AddIsoform < ActiveRecord::Migration
  def self.up
    create_table :isoforms do |t|
      t.string   :ac
      t.string   :name
      t.text     :sequence
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :protein_id
    end
    add_index :isoforms, [:protein_id]

    add_column :cleavages, :proteaseisoform_id, :integer
    add_column :cleavages, :proteasechain_id, :integer
    add_column :cleavages, :substateisoform_id, :integer
    add_column :cleavages, :substratechain_id, :integer

    add_column :chains, :isoform_id, :integer
    add_column :chains, :chain_id, :integer

    add_index :cleavages, [:proteaseisoform_id]
    add_index :cleavages, [:proteasechain_id]
    add_index :cleavages, [:substateisoform_id]
    add_index :cleavages, [:substratechain_id]

    add_index :chains, [:isoform_id]
    add_index :chains, [:chain_id]

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :cleavages, :proteaseisoform_id
    remove_column :cleavages, :proteasechain_id
    remove_column :cleavages, :substateisoform_id
    remove_column :cleavages, :substratechain_id

    remove_column :chains, :isoform_id
    remove_column :chains, :chain_id

    drop_table :isoforms

    remove_index :cleavages, :name => :index_cleavages_on_proteaseisoform_id rescue ActiveRecord::StatementInvalid
    remove_index :cleavages, :name => :index_cleavages_on_proteasechain_id rescue ActiveRecord::StatementInvalid
    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid
    remove_index :cleavages, :name => :index_cleavages_on_substratechain_id rescue ActiveRecord::StatementInvalid

    remove_index :chains, :name => :index_chains_on_isoform_id rescue ActiveRecord::StatementInvalid
    remove_index :chains, :name => :index_chains_on_chain_id rescue ActiveRecord::StatementInvalid

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
