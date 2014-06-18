class ModifyImport < ActiveRecord::Migration
  def self.up
    add_column :imports, :idtype, :string
  end

  def self.down
    remove_column :imports, :idtype
  end
end
