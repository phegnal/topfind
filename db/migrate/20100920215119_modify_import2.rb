class ModifyImport2 < ActiveRecord::Migration
  def self.up
    rename_column :imports, :list_updated_at, :csvfile_updated_at
    rename_column :imports, :list_content_type, :csvfile_content_type
    rename_column :imports, :list_file_name, :csvfile_file_name
    rename_column :imports, :list_file_size, :csvfile_file_size
  end

  def self.down
    rename_column :imports, :csvfile_updated_at, :list_updated_at
    rename_column :imports, :csvfile_content_type, :list_content_type
    rename_column :imports, :csvfile_file_name, :list_file_name
    rename_column :imports, :csvfile_file_size, :list_file_size
  end
end
