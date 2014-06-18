class CreateEvidences < ActiveRecord::Migration
  def self.up
    create_table :evidences do |t|
      t.string   :name
      t.string   :method
      t.text     :description
      t.string   :phys_relevance, :default => :unknown
      t.string   :directness, :default => :unknown
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :evidences
  end
end
