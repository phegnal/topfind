class AddInhibitionsAndMolecules < ActiveRecord::Migration
  def self.up
    create_table :molecules do |t|
      t.string   :name
      t.text     :description
      t.string   :formula
      t.string   :external_id
      t.string   :source
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :inhibitions do |t|
      t.integer  :import_id
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :protease_id
      t.integer  :inhibitor_id
      t.integer  :molecule_id
      t.integer  :inhibitory_molecule_id
    end
    add_index :inhibitions, [:protease_id]
    add_index :inhibitions, [:inhibitor_id]
    add_index :inhibitions, [:molecule_id]
    add_index :inhibitions, [:inhibitory_molecule_id]
  end

  def self.down
    drop_table :molecules
    drop_table :inhibitions
  end
end
