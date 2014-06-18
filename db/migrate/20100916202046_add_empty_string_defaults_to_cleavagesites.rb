class AddEmptyStringDefaultsToCleavagesites < ActiveRecord::Migration
  def self.up
    change_column :cleavagesites, :p5p, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p1, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p4p, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p2, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p3p, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p3, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p2p, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p10p, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p10, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p4, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p1p, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p5, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p6, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p7, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p9p, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p8, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p8p, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p9, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p7p, :string, :default => "", :limit => 255
    change_column :cleavagesites, :p6p, :string, :default => "", :limit => 255
  end

  def self.down
    change_column :cleavagesites, :p5p, :string
    change_column :cleavagesites, :p1, :string
    change_column :cleavagesites, :p4p, :string
    change_column :cleavagesites, :p2, :string
    change_column :cleavagesites, :p3p, :string
    change_column :cleavagesites, :p3, :string
    change_column :cleavagesites, :p2p, :string
    change_column :cleavagesites, :p10p, :string
    change_column :cleavagesites, :p10, :string
    change_column :cleavagesites, :p4, :string
    change_column :cleavagesites, :p1p, :string
    change_column :cleavagesites, :p5, :string
    change_column :cleavagesites, :p6, :string
    change_column :cleavagesites, :p7, :string
    change_column :cleavagesites, :p9p, :string
    change_column :cleavagesites, :p8, :string
    change_column :cleavagesites, :p8p, :string
    change_column :cleavagesites, :p9, :string
    change_column :cleavagesites, :p7p, :string
    change_column :cleavagesites, :p6p, :string
  end
end
