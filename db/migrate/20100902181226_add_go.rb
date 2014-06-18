class AddGo < ActiveRecord::Migration
  def self.up
    create_table :goprocesses do |t|
      t.string   :id
      t.string   :acc
      t.string   :name
      t.text     :description
      t.boolean  :is_obsolete
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :gofunctions do |t|
      t.string   :id
      t.string   :acc
      t.string   :name
      t.text     :description
      t.boolean  :is_obsolete
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :golinks do |t|
      t.boolean  :direct
      t.integer  :count
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :descendant_type
      t.string   :ancestor_type
      t.integer  :descendant_id
      t.integer  :ancestor_id
    end
    add_index :golinks, [:ancestor_type, :ancestor_id]
    add_index :golinks, [:descendant_type, :descendant_id]

    create_table :gocomponents do |t|
      t.string   :id
      t.string   :acc
      t.string   :name
      t.text     :description
      t.boolean  :is_obsolete
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :goprocesses
    drop_table :gofunctions
    drop_table :golinks
    drop_table :gocomponents
  end
end
