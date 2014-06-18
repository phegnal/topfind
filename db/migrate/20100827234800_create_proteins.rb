class CreateProteins < ActiveRecord::Migration
  def self.up
    create_table :proteins do |t|
      t.string   :ac
      t.string   :name
      t.string   :data_class
      t.integer  :molecular_type
      t.string   :entry_type
      t.string   :dt_create
      t.string   :dt_sequence
      t.string   :dt_annotation
      t.string   :definition
      t.text     :sequence
      t.integer  :mw
      t.string   :crc64
      t.integer  :aalen
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :users do |t|
      t.string   :crypted_password, :limit => 40
      t.string   :salt, :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :name
      t.string   :email_address
      t.boolean  :administrator, :default => false
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :state, :default => "active"
      t.datetime :key_timestamp
    end
    add_index :users, [:state]
  end

  def self.down
    drop_table :proteins
    drop_table :users
  end
end
