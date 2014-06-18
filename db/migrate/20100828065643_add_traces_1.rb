class AddTraces1 < ActiveRecord::Migration
  def self.up
    create_table :traces do |t|
      t.string   :name
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :traceexternals do |t|
      t.string   :dbid
      t.string   :dbname
      t.string   :dburl
      t.string   :dbdesc
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :complexities do |t|
      t.string   :name
      t.text     :description
      t.float    :factor
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :traces
    drop_table :traceexternals
    drop_table :complexities
  end
end
