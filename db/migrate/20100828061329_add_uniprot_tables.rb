class AddUniprotTables < ActiveRecord::Migration
  def self.up
    # proteins is handled by hobo model centric system
    # create_table(:proteins) do |t|
    #   t.column(:ac, :string)
    #   t.column(:name, :string)
    #   t.column(:data_class, :string)
    #   t.column(:molecular_type, :string)
    #   t.column(:entry_type, :string)
    #   t.column(:dt_create, :string)
    #   t.column(:dt_sequence, :string)
    #   t.column(:dt_annotation, :string)
    #   t.column(:definition, :string)
    #   t.column(:sequence, :text)
    #   t.column(:mw, :integer)
    #   t.column(:crc64, :string)
    #   t.column(:aalen, :integer)
    #   t.timestamps
    # end
    # add_index(:proteins, :name)
    # add_index(:proteins, :ac)
    
    create_table(:proteinnames) do |t|
      t.column(:protein_id, :string)
      t.column(:full, :string)
      t.column(:short, :string)
      t.column(:recommended, :boolean)
    end
    add_index (:proteinnames, :full)
    add_index (:proteinnames, :short)
    add_index (:proteinnames, :protein_id)

    create_table(:acs) do |t|
      t.column(:protein_id, :string)
      t.column(:name, :string)
    end
    add_index(:acs, :name)
    add_index(:acs, :protein_id)

    create_table(:gns) do |t|
      t.column(:name, :string)
      t.column(:protein_id, :string)
    end
    add_index(:gns, :name)
    add_index(:gns, :protein_id)

    create_table(:gn_synonyms) do |t|
      t.column(:gn_id, :integer)
      t.column(:synonym, :integer)
    end
    add_index(:gn_synonyms, :synonym)
    add_index(:gn_synonyms, :gn_id)

    create_table(:gn_loci) do |t|
      t.column(:gn_id, :integer)
      t.column(:locus, :integer)
    end
    add_index(:gn_loci, :locus)
    add_index(:gn_loci, :gn_id)

    create_table(:gn_orf_names) do |t|
      t.column(:gn_id, :integer)
      t.column(:name, :integer)
    end
    add_index(:gn_orf_names, :name)
    add_index(:gn_orf_names, :gn_id)

    create_table(:oss_proteins, :id => false) do |t|
      t.column(:protein_id, :integer)
      t.column(:os_id, :integer)
    end
    add_index(:oss_proteins, :protein_id)
    add_index(:oss_proteins, :os_id)

    create_table(:oss) do |t|
      t.column(:name, :string)
      t.column(:common_name, :string)
    end
    add_index(:oss, :name)

    create_table(:ocs_proteins, :id => false) do |t|
      t.column(:protein_id, :integer)
      t.column(:oc_id, :integer)
    end
    add_index(:ocs_proteins, :protein_id)
    add_index(:ocs_proteins, :oc_id)

    create_table(:ocs) do |t|
      t.column(:level, :integer)
      t.column(:name, :string)
    end
    add_index(:ocs, :name)

    create_table(:oxs_proteins, :id => false) do |t|
      t.column(:protein_id, :integer)
      t.column(:ox_id, :integer)
    end
    add_index(:oxs_proteins, :protein_id)
    add_index(:oxs_proteins, :ox_id)

    create_table(:oxs) do |t|
      t.column(:db_name, :string)
      t.column(:accession, :string)
    end
    add_index(:oxs, :db_name)
    add_index(:oxs, :accession)

    # references
    create_table(:refs) do |t|
      t.column(:protein_id, :integer)
      t.column(:title, :string)
      t.column(:auther, :string)
      t.column(:location, :string)
    end
    add_index(:refs, :location)
    add_index(:refs, :protein_id)
    create_table(:rxs) do |t|
      t.column(:name, :string)
      t.column(:identifier, :string)
      t.column(:ref_id, :integer)
    end
    add_index(:rxs, :name)
    create_table(:rgs) do |t|
      t.column(:name, :string)
      t.column(:ref_id, :integer)
    end
    add_index(:rgs, :name)
    create_table(:rps) do |t|
      t.column(:comment, :string)
      t.column(:ref_id, :integer)
    end
    add_index(:rps, :comment)
    create_table(:rcs) do |t|
      t.column(:token, :string)
      t.column(:text, :string)
      t.column(:ref_id, :integer)
    end
    add_index(:rcs, :token)

    create_table(:ccs) do |t|
      t.column(:topic, :string)
      t.column(:contents, :text)
      t.column(:protein_id, :string)
    end
    add_index(:ccs, :protein_id)
    add_index(:ccs, :topic)
    
    create_table(:drs) do |t|
      t.column(:protein_id, :string)
      t.column(:db_name, :string)
      t.column(:protein_name, :string)
      t.column(:content1, :string)
      t.column(:content2, :string)
      t.column(:content3, :string)
    end
    add_index(:drs, :protein_id)
    add_index(:drs, :db_name)
    add_index(:drs, :protein_name)

    create_table(:kws_proteins, :id => false) do |t|
      t.column(:protein_id, :integer)
      t.column(:kw_id, :integer)
    end
    add_index(:kws_proteins, :protein_id)
    add_index(:kws_proteins, :kw_id)

    create_table(:kws) do |t|
      t.column(:name, :string)
    end
    add_index(:kws, :name)

    create_table(:fts) do |t|
      t.column(:protein_id, :string)
      t.column(:name, :string)
      t.column(:from, :string)
      t.column(:to, :string)
      t.column(:description, :string)
      t.column(:ftid, :string)
    end
    add_index(:fts, :protein_id)
    add_index(:fts, :name)
    add_index(:fts, :ftid)
  end

  def self.down
    # drop_table :proteins
    drop_table :proteinnames
    drop_table :acs
    drop_table :gns
    drop_table :gn_synonyms
    drop_table :gn_loci
    drop_table :gn_orf_names
    drop_table :ccs
    drop_table :drs
    drop_table :kws
    drop_table :fts
    drop_table :ocs
    drop_table :oxs
    drop_table :oss
    drop_table :oss_proteins
    drop_table :kws_proteins
    drop_table :oxs_proteins
    drop_table :ocs_proteins
    drop_table :rcs
    drop_table :refs
    drop_table :rgs
    drop_table :rps
    drop_table :rxs
  end
end



