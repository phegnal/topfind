class AddImport < ActiveRecord::Migration
  def self.up
    create_table :imports do |t|
      t.string   :name
      t.text     :description
      t.integer  :inhibitions_listed
      t.integer  :inhibitions_imported
      t.integer  :cleavages_listed
      t.integer  :cleavages_imported
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :list_file_name
      t.string   :list_content_type
      t.integer  :list_file_size
      t.datetime :list_updated_at
    end
  end

  def self.down
    drop_table :imports
  end
end
