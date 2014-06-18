class ModifyImport3 < ActiveRecord::Migration
  def self.up
    change_column :imports, :cleavages_listed, :integer, :default => 0, :limit => 4
    change_column :imports, :inhibitions_listed, :integer, :default => 0, :limit => 4
    change_column :imports, :inhibitions_imported, :integer, :default => 0, :limit => 4
    change_column :imports, :cleavages_imported, :integer, :default => 0, :limit => 4
  end

  def self.down
    change_column :imports, :cleavages_listed, :integer
    change_column :imports, :inhibitions_listed, :integer
    change_column :imports, :inhibitions_imported, :integer
    change_column :imports, :cleavages_imported, :integer
  end
end
