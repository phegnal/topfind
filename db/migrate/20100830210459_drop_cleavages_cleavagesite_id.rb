class DropCleavagesCleavagesiteId < ActiveRecord::Migration
  def self.up
    remove_column :cleavages, :cleavagesite_id
  end

  def self.down
    add_column :cleavages, :cleavagesite_id, :integer
  end
end
