class AddConfidence < ActiveRecord::Migration
  def self.up
    add_column :nterm2evidences, :confidence, :float
    add_column :nterm2evidences, :confidence_type, :string, :default => "unknown"

    add_column :cterm2evidences, :confidence, :float
    add_column :cterm2evidences, :confidence_type, :string, :default => "unknown"

    add_index :nterm2evidences, [:confidence]
    add_index :nterm2evidences, [:confidence_type]

    add_index :cterm2evidences, [:confidence]
    add_index :cterm2evidences, [:confidence_type]

  end

  def self.down
    remove_column :nterm2evidences, :confidence
    remove_column :nterm2evidences, :confidence_type

    remove_column :cterm2evidences, :confidence
    remove_column :cterm2evidences, :confidence_type
    remove_index :nterm2evidences, :name => :index_nterm2evidences_on_confidence rescue ActiveRecord::StatementInvalid
    remove_index :nterm2evidences, :name => :index_nterm2evidences_on_confidence_type rescue ActiveRecord::StatementInvalid

    remove_index :cterm2evidences, :name => :index_cterm2evidences_on_confidence rescue ActiveRecord::StatementInvalid
    remove_index :cterm2evidences, :name => :index_cterm2evidences_on_confidence_type rescue ActiveRecord::StatementInvalid
  end
end
