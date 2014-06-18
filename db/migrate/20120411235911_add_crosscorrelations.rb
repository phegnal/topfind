class AddCrosscorrelations < ActiveRecord::Migration
  def self.up
    create_table :crosscorrelations do |t|
      t.integer  :id
      t.string   :name
      t.string   :email
      t.text     :desc
      t.text     :ntermini
      t.text     :ctermini
      t.text     :cleavagesites
      t.string   :ip
      t.datetime :created_at
      t.datetime :updated_at
    end

    remove_index :evidencerelations, :name => :index_evidencerelations_on_traceables_type_and_traceables_id rescue ActiveRecord::StatementInvalid

    remove_index :cleavages, :name => :index_cleavages_on_substateisoform_id rescue ActiveRecord::StatementInvalid

    remove_index :nterms, :name => :true rescue ActiveRecord::StatementInvalid
    add_index :nterms, [:seqexcerpt], :name => 'true'

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name], :unique => true

    remove_index :proteins, :name => :meropsfamily rescue ActiveRecord::StatementInvalid

    remove_index :cterms, :name => :true rescue ActiveRecord::StatementInvalid
    add_index :cterms, [:seqexcerpt], :name => 'true'

    remove_index :evidence2tissues, :name => :index_trace2tissues_on_tissue_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    drop_table :crosscorrelations

    add_index :evidencerelations, [:traceable_id], :name => 'index_evidencerelations_on_traceables_type_and_traceables_id'

    add_index :cleavages, [:substrateisoform_id], :name => 'index_cleavages_on_substateisoform_id'

    remove_index :nterms, :name => :true rescue ActiveRecord::StatementInvalid
    add_index :nterms, [:seqexcerpt], :name => 'true'

    remove_index :kws, :name => :index_kws_on_name rescue ActiveRecord::StatementInvalid
    add_index :kws, [:name]

    add_index :proteins, [:meropsfamily], :name => 'meropsfamily'

    remove_index :cterms, :name => :true rescue ActiveRecord::StatementInvalid
    add_index :cterms, [:seqexcerpt], :name => 'true'

    add_index :evidence2tissues, [:tissue_id], :name => 'index_trace2tissues_on_tissue_id'
  end
end
