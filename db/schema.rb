# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120411235911) do

  create_table "acs", :force => true do |t|
    t.string "protein_id"
    t.string "name"
  end

  add_index "acs", ["name"], :name => "index_acs_on_name"
  add_index "acs", ["protein_id"], :name => "index_acs_on_protein_id"

  create_table "ccs", :force => true do |t|
    t.string "topic"
    t.text   "contents"
    t.string "protein_id"
  end

  add_index "ccs", ["protein_id"], :name => "index_ccs_on_protein_id"
  add_index "ccs", ["topic"], :name => "index_ccs_on_topic"

  create_table "chain2evidences", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evidence_id"
    t.integer  "chain_id"
  end

  add_index "chain2evidences", ["chain_id"], :name => "index_chain2evidences_on_chain_id"
  add_index "chain2evidences", ["evidence_id"], :name => "index_chain2evidences_on_evidence_id"

  create_table "chains", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "protein_id"
    t.integer  "cterm_id"
    t.integer  "nterm_id"
    t.integer  "isoform_id"
    t.string   "idstring"
    t.integer  "from"
    t.integer  "to"
  end

  add_index "chains", ["cterm_id"], :name => "index_chains_on_cterm_id"
  add_index "chains", ["isoform_id"], :name => "index_chains_on_isoform_id"
  add_index "chains", ["nterm_id"], :name => "index_chains_on_nterm_id"
  add_index "chains", ["protein_id"], :name => "index_chains_on_protein_id"

  create_table "cleavage2evidences", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evidence_id"
    t.integer  "cleavage_id"
  end

  add_index "cleavage2evidences", ["cleavage_id"], :name => "index_cleavage2evidences_on_cleavage_id"
  add_index "cleavage2evidences", ["evidence_id"], :name => "index_cleavage2evidences_on_evidence_id"

  create_table "cleavages", :force => true do |t|
    t.integer  "protease_id"
    t.integer  "substrate_id"
    t.integer  "import_id"
    t.integer  "pos"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cterm_id"
    t.integer  "nterm_id"
    t.integer  "cleavagesite_id"
    t.integer  "proteaseisoform_id"
    t.integer  "proteasechain_id"
    t.integer  "substrateisoform_id"
    t.integer  "substratechain_id"
    t.string   "idstring"
    t.string   "peptide"
  end

  add_index "cleavages", ["cleavagesite_id"], :name => "index_cleavages_on_cleavagesite_id"
  add_index "cleavages", ["cterm_id"], :name => "index_cleavages_on_cterm_id"
  add_index "cleavages", ["import_id"], :name => "index_cleavages_on_import_id"
  add_index "cleavages", ["nterm_id"], :name => "index_cleavages_on_nterm_id"
  add_index "cleavages", ["protease_id"], :name => "index_cleavages_on_protease_id"
  add_index "cleavages", ["proteasechain_id"], :name => "index_cleavages_on_proteasechain_id"
  add_index "cleavages", ["proteaseisoform_id"], :name => "index_cleavages_on_proteaseisoform_id"
  add_index "cleavages", ["substrate_id"], :name => "index_cleavages_on_substrate_id"
  add_index "cleavages", ["substratechain_id"], :name => "index_cleavages_on_substratechain_id"
  add_index "cleavages", ["substrateisoform_id"], :name => "index_cleavages_on_substateisoform_id"
  add_index "cleavages", ["substrateisoform_id"], :name => "index_cleavages_on_substrateisoform_id"

  create_table "cleavagesites", :force => true do |t|
    t.string   "p10",        :default => ""
    t.string   "p9",         :default => ""
    t.string   "p8",         :default => ""
    t.string   "p7",         :default => ""
    t.string   "p6",         :default => ""
    t.string   "p5",         :default => ""
    t.string   "p4",         :default => ""
    t.string   "p3",         :default => ""
    t.string   "p2",         :default => ""
    t.string   "p1",         :default => ""
    t.string   "p1p",        :default => ""
    t.string   "p2p",        :default => ""
    t.string   "p3p",        :default => ""
    t.string   "p4p",        :default => ""
    t.string   "p5p",        :default => ""
    t.string   "p6p",        :default => ""
    t.string   "p7p",        :default => ""
    t.string   "p8p",        :default => ""
    t.string   "p9p",        :default => ""
    t.string   "p10p",       :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "import_id"
    t.string   "idstring"
  end

  add_index "cleavagesites", ["import_id"], :name => "index_cleavagesites_on_import_id"

  create_table "crosscorrelations", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "desc"
    t.text     "ntermini"
    t.text     "ctermini"
    t.text     "cleavagesites"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cterm2evidences", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evidence_id"
    t.integer  "cterm_id"
  end

  add_index "cterm2evidences", ["cterm_id"], :name => "index_cterm2evidences_on_cterm_id"
  add_index "cterm2evidences", ["evidence_id"], :name => "index_cterm2evidences_on_evidence_id"

  create_table "cterms", :force => true do |t|
    t.integer  "protein_id"
    t.integer  "pos"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "import_id"
    t.string   "idstring"
    t.integer  "isoform_id"
    t.integer  "terminusmodification_id"
    t.string   "seqexcerpt"
  end

  add_index "cterms", ["import_id"], :name => "index_cterms_on_import_id"
  add_index "cterms", ["isoform_id"], :name => "index_cterms_on_isoform_id"
  add_index "cterms", ["protein_id"], :name => "index_cterms_on_protein_id"
  add_index "cterms", ["seqexcerpt"], :name => "true"
  add_index "cterms", ["terminusmodification_id"], :name => "index_cterms_on_terminusmodification_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "documentations", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "long"
    t.text     "short"
    t.string   "category"
    t.integer  "position",   :default => 0
    t.boolean  "show",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "drs", :force => true do |t|
    t.string "protein_id"
    t.string "db_name"
    t.string "protein_name"
    t.string "content1"
    t.string "content2"
    t.string "content3"
  end

  add_index "drs", ["db_name"], :name => "index_drs_on_db_name"
  add_index "drs", ["protein_id"], :name => "index_drs_on_protein_id"
  add_index "drs", ["protein_name"], :name => "index_drs_on_protein_name"

  create_table "evidence2evidencecodes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evidence_id"
    t.integer  "code"
  end

  add_index "evidence2evidencecodes", ["code"], :name => "index_evidence2evidencecodes_on_code"
  add_index "evidence2evidencecodes", ["evidence_id"], :name => "index_evidence2evidencecodes_on_evidence_id"

  create_table "evidence2gocomponents", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evidence_id"
    t.integer  "gocomponent_id"
  end

  add_index "evidence2gocomponents", ["evidence_id"], :name => "index_evidence2gocomponents_on_evidence_id"
  add_index "evidence2gocomponents", ["gocomponent_id"], :name => "index_evidence2gocomponents_on_gocomponent_id"

  create_table "evidence2publications", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evidence_id"
    t.integer  "publication_id"
  end

  add_index "evidence2publications", ["evidence_id"], :name => "index_evidence2publications_on_evidence_id"
  add_index "evidence2publications", ["publication_id"], :name => "index_evidence2publications_on_publication_id"

  create_table "evidence2tissues", :force => true do |t|
    t.integer  "tissue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evidence_id"
  end

  add_index "evidence2tissues", ["evidence_id"], :name => "index_evidence2tissues_on_evidence_id"
  add_index "evidence2tissues", ["tissue_id"], :name => "index_evidence2tissues_on_tissue_id"
  add_index "evidence2tissues", ["tissue_id"], :name => "index_trace2tissues_on_tissue_id"

  create_table "evidencecodes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.text     "definition"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "evidencerelations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evidence_id"
    t.integer  "traceable_id"
    t.string   "traceable_type"
  end

  add_index "evidencerelations", ["evidence_id"], :name => "index_evidencerelations_on_evidence_id"
  add_index "evidencerelations", ["traceable_id"], :name => "index_evidencerelations_on_traceables_type_and_traceables_id"
  add_index "evidencerelations", ["traceable_type", "traceable_id"], :name => "index_evidencerelations_on_traceable_type_and_traceable_id"

  create_table "evidences", :force => true do |t|
    t.string   "name"
    t.string   "method"
    t.string   "protease_inhibitors_used"
    t.text     "description"
    t.string   "phys_relevance",                :default => "unknown"
    t.string   "directness",                    :default => "unknown"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "evidencefile_file_name"
    t.string   "evidencefile_content_type"
    t.integer  "evidencefile_file_size"
    t.datetime "evidencefile_updated_at"
    t.integer  "owner_id"
    t.string   "idstring"
    t.string   "repository"
    t.string   "lab"
    t.integer  "evidencesource_id"
    t.float    "confidence"
    t.string   "confidence_type",               :default => "unknown"
    t.string   "method_system",                 :default => "unknown"
    t.string   "method_protease_source",        :default => "unknown"
    t.string   "methodology",                   :default => "unknown"
    t.string   "proteaseassignment_confidence", :default => "unknown"
  end

  add_index "evidences", ["directness"], :name => "index_evidences_on_directness"
  add_index "evidences", ["evidencesource_id"], :name => "index_evidences_on_evidencesource_id"
  add_index "evidences", ["lab"], :name => "index_evidences_on_lab"
  add_index "evidences", ["method"], :name => "index_evidences_on_method"
  add_index "evidences", ["method_protease_source"], :name => "index_evidences_on_method_protease_source"
  add_index "evidences", ["method_system"], :name => "index_evidences_on_method_system"
  add_index "evidences", ["methodology"], :name => "index_evidences_on_methodology"
  add_index "evidences", ["name"], :name => "index_evidences_on_name"
  add_index "evidences", ["owner_id"], :name => "index_evidences_on_owner_id"
  add_index "evidences", ["phys_relevance"], :name => "index_evidences_on_phys_relevance"
  add_index "evidences", ["proteaseassignment_confidence"], :name => "index_evidences_on_proteaseassignment_confidence"

  create_table "evidencesources", :force => true do |t|
    t.string   "dbid"
    t.string   "dbname"
    t.string   "dburl"
    t.string   "dbdesc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fts", :force => true do |t|
    t.string "protein_id"
    t.string "name"
    t.string "from"
    t.string "to"
    t.string "description"
    t.string "ftid"
  end

  add_index "fts", ["ftid"], :name => "index_fts_on_ftid"
  add_index "fts", ["name"], :name => "index_fts_on_name"
  add_index "fts", ["protein_id"], :name => "index_fts_on_protein_id"

  create_table "gn_loci", :force => true do |t|
    t.integer "gn_id"
    t.integer "locus"
  end

  add_index "gn_loci", ["gn_id"], :name => "index_gn_loci_on_gn_id"
  add_index "gn_loci", ["locus"], :name => "index_gn_loci_on_locus"

  create_table "gn_orf_names", :force => true do |t|
    t.integer "gn_id"
    t.integer "name"
  end

  add_index "gn_orf_names", ["gn_id"], :name => "index_gn_orf_names_on_gn_id"
  add_index "gn_orf_names", ["name"], :name => "index_gn_orf_names_on_name"

  create_table "gn_synonyms", :force => true do |t|
    t.integer "gn_id"
    t.string  "synonym"
  end

  add_index "gn_synonyms", ["gn_id"], :name => "index_gn_synonyms_on_gn_id"
  add_index "gn_synonyms", ["synonym"], :name => "index_gn_synonyms_on_synonym"

  create_table "gns", :force => true do |t|
    t.string "name"
    t.string "protein_id"
  end

  add_index "gns", ["name"], :name => "index_gns_on_name"
  add_index "gns", ["protein_id"], :name => "index_gns_on_protein_id"

  create_table "gocomponents", :force => true do |t|
    t.string   "acc"
    t.string   "name"
    t.text     "description"
    t.boolean  "is_obsolete"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gofunctionlinks", :force => true do |t|
    t.boolean  "direct"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "descendant_id"
    t.integer  "ancestor_id"
  end

  add_index "gofunctionlinks", ["ancestor_id"], :name => "index_gofunctionlinks_on_ancestor_id"
  add_index "gofunctionlinks", ["descendant_id"], :name => "index_gofunctionlinks_on_descendant_id"

  create_table "gofunctions", :force => true do |t|
    t.string   "acc"
    t.string   "name"
    t.text     "description"
    t.boolean  "is_obsolete"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "golinks", :force => true do |t|
    t.boolean  "direct"
    t.integer  "count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "descendant_type"
    t.string   "ancestor_type"
    t.integer  "descendant_id"
    t.integer  "ancestor_id"
  end

  add_index "golinks", ["ancestor_type", "ancestor_id"], :name => "index_golinks_on_ancestor_type_and_ancestor_id"
  add_index "golinks", ["descendant_type", "descendant_id"], :name => "index_golinks_on_descendant_type_and_descendant_id"

  create_table "goprocesses", :force => true do |t|
    t.string   "acc"
    t.string   "name"
    t.text     "description"
    t.boolean  "is_obsolete"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imports", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "inhibitions_listed",     :default => 0
    t.integer  "inhibitions_imported",   :default => 0
    t.integer  "cleavages_listed",       :default => 0
    t.integer  "cleavages_imported",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "csvfile_file_name"
    t.string   "csvfile_content_type"
    t.integer  "csvfile_file_size"
    t.datetime "csvfile_updated_at"
    t.integer  "cterms_listed",          :default => 0
    t.integer  "cterms_imported",        :default => 0
    t.integer  "nterms_listed",          :default => 0
    t.integer  "nterms_imported",        :default => 0
    t.integer  "owner_id"
    t.integer  "evidence_id"
    t.string   "datatype"
    t.integer  "cleavagesites_listed",   :default => 0
    t.integer  "cleavagesites_imported", :default => 0
  end

  add_index "imports", ["evidence_id"], :name => "index_imports_on_evidence_id"
  add_index "imports", ["owner_id"], :name => "index_imports_on_owner_id"

  create_table "inhibition2evidences", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evidence_id"
    t.integer  "inhibition_id"
  end

  add_index "inhibition2evidences", ["evidence_id"], :name => "index_inhibition2evidences_on_evidence_id"
  add_index "inhibition2evidences", ["inhibition_id"], :name => "index_inhibition2evidences_on_inhibition_id"

  create_table "inhibitions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inhibitor_id"
    t.integer  "molecule_id"
    t.integer  "inhibitory_molecule_id"
    t.integer  "inhibited_proteaseisoform_id"
    t.integer  "inhibited_proteasechain_id"
    t.integer  "inhibitorisoform_id"
    t.integer  "inhibitorchain_id"
    t.integer  "inhibited_protease_id"
    t.string   "idstring"
    t.integer  "import_id"
  end

  add_index "inhibitions", ["import_id"], :name => "index_inhibitions_on_import_id"
  add_index "inhibitions", ["inhibited_protease_id"], :name => "index_inhibitions_on_inhibited_protease_id"
  add_index "inhibitions", ["inhibited_proteasechain_id"], :name => "index_inhibitions_on_inhibited_proteasechain_id"
  add_index "inhibitions", ["inhibited_proteaseisoform_id"], :name => "index_inhibitions_on_inhibited_proteaseisoform_id"
  add_index "inhibitions", ["inhibitor_id"], :name => "index_inhibitions_on_inhibitor_id"
  add_index "inhibitions", ["inhibitorchain_id"], :name => "index_inhibitions_on_inhibitorchain_id"
  add_index "inhibitions", ["inhibitorisoform_id"], :name => "index_inhibitions_on_inhibitorisoform_id"
  add_index "inhibitions", ["inhibitory_molecule_id"], :name => "index_inhibitions_on_inhibitory_molecule_id"
  add_index "inhibitions", ["molecule_id"], :name => "index_inhibitions_on_molecule_id"

  create_table "isoforms", :force => true do |t|
    t.string   "ac"
    t.string   "name"
    t.text     "sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "protein_id"
    t.string   "status",     :default => "unknown"
  end

  add_index "isoforms", ["protein_id"], :name => "index_isoforms_on_protein_id"

  create_table "kws", :force => true do |t|
    t.string "name"
    t.string "ac"
    t.text   "description"
    t.string "category"
  end

  add_index "kws", ["ac"], :name => "index_kws_on_ac"
  add_index "kws", ["category"], :name => "index_kws_on_category"
  add_index "kws", ["name"], :name => "index_kws_on_name"

  create_table "kws_proteins", :id => false, :force => true do |t|
    t.integer "protein_id"
    t.integer "kw_id"
  end

  add_index "kws_proteins", ["kw_id"], :name => "index_kws_proteins_on_kw_id"
  add_index "kws_proteins", ["protein_id"], :name => "index_kws_proteins_on_protein_id"

  create_table "kwsynonymes", :force => true do |t|
    t.string  "name"
    t.integer "kw_id"
  end

  add_index "kwsynonymes", ["kw_id"], :name => "index_kwsynonymes_on_kw_id"
  add_index "kwsynonymes", ["name"], :name => "index_kwsynonymes_on_name", :unique => true

  create_table "moleculenames", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "molecule_id"
  end

  add_index "moleculenames", ["molecule_id"], :name => "index_moleculenames_on_molecule_id"

  create_table "molecules", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "formula"
    t.string   "external_id"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nterm2evidences", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evidence_id"
    t.integer  "nterm_id"
  end

  add_index "nterm2evidences", ["evidence_id"], :name => "index_nterm2evidences_on_evidence_id"
  add_index "nterm2evidences", ["nterm_id"], :name => "index_nterm2evidences_on_nterm_id"

  create_table "nterms", :force => true do |t|
    t.integer  "protein_id"
    t.integer  "pos"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "import_id"
    t.string   "idstring"
    t.integer  "isoform_id"
    t.integer  "terminusmodification_id"
    t.string   "seqexcerpt"
  end

  add_index "nterms", ["import_id"], :name => "index_nterms_on_import_id"
  add_index "nterms", ["isoform_id"], :name => "index_nterms_on_isoform_id"
  add_index "nterms", ["protein_id"], :name => "index_nterms_on_protein_id"
  add_index "nterms", ["seqexcerpt"], :name => "true"
  add_index "nterms", ["terminusmodification_id"], :name => "index_nterms_on_terminusmodification_id"

  create_table "ocs", :force => true do |t|
    t.integer "level"
    t.string  "name"
  end

  add_index "ocs", ["name"], :name => "index_ocs_on_name"

  create_table "ocs_proteins", :id => false, :force => true do |t|
    t.integer "protein_id"
    t.integer "oc_id"
  end

  add_index "ocs_proteins", ["oc_id"], :name => "index_ocs_proteins_on_oc_id"
  add_index "ocs_proteins", ["protein_id"], :name => "index_ocs_proteins_on_protein_id"

  create_table "oss", :force => true do |t|
    t.string "name"
    t.string "common_name"
  end

  add_index "oss", ["name"], :name => "index_oss_on_name"

  create_table "oss_proteins", :id => false, :force => true do |t|
    t.integer "protein_id"
    t.integer "os_id"
  end

  add_index "oss_proteins", ["os_id"], :name => "index_oss_proteins_on_os_id"
  add_index "oss_proteins", ["protein_id"], :name => "index_oss_proteins_on_protein_id"

  create_table "oxs", :force => true do |t|
    t.string "db_name"
    t.string "accession"
  end

  add_index "oxs", ["accession"], :name => "index_oxs_on_accession"
  add_index "oxs", ["db_name"], :name => "index_oxs_on_db_name"

  create_table "oxs_proteins", :id => false, :force => true do |t|
    t.integer "protein_id"
    t.integer "ox_id"
  end

  add_index "oxs_proteins", ["ox_id"], :name => "index_oxs_proteins_on_ox_id"
  add_index "oxs_proteins", ["protein_id"], :name => "index_oxs_proteins_on_protein_id"

  create_table "proteinnames", :force => true do |t|
    t.string  "protein_id"
    t.string  "full"
    t.string  "short"
    t.boolean "recommended"
  end

  add_index "proteinnames", ["full"], :name => "index_proteinnames_on_full"
  add_index "proteinnames", ["protein_id"], :name => "index_proteinnames_on_protein_id"
  add_index "proteinnames", ["short"], :name => "index_proteinnames_on_short"

  create_table "proteins", :force => true do |t|
    t.string   "ac"
    t.string   "name"
    t.integer  "molecular_type"
    t.string   "entry_type"
    t.string   "dt_create"
    t.string   "dt_sequence"
    t.string   "dt_annotation"
    t.string   "definition"
    t.text     "sequence"
    t.integer  "mw"
    t.string   "crc64"
    t.integer  "aalen"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",          :default => "unknown"
    t.string   "data_class"
    t.string   "chromosome"
    t.string   "band"
    t.integer  "species_id"
    t.string   "meropsfamily"
    t.string   "meropssubfamily"
    t.string   "meropscode"
  end

  add_index "proteins", ["ac"], :name => "index_proteins_on_ac", :unique => true
  add_index "proteins", ["band"], :name => "index_proteins_on_band"
  add_index "proteins", ["chromosome"], :name => "index_proteins_on_chromosome"
  add_index "proteins", ["meropscode"], :name => "index_proteins_on_meropscode"
  add_index "proteins", ["meropsfamily"], :name => "index_proteins_on_meropsfamily"
  add_index "proteins", ["meropsfamily"], :name => "meropsfamily"
  add_index "proteins", ["meropssubfamily"], :name => "index_proteins_on_meropssubfamily"
  add_index "proteins", ["name"], :name => "index_proteins_on_name", :unique => true
  add_index "proteins", ["species_id"], :name => "index_proteins_on_species_id"

  create_table "proteins_oss", :id => false, :force => true do |t|
    t.integer "os_id"
    t.integer "protein_id"
  end

  create_table "proteins_oxs", :id => false, :force => true do |t|
    t.integer "ox_id"
    t.integer "protein_id"
  end

  create_table "publications", :force => true do |t|
    t.integer  "pmid"
    t.string   "title"
    t.text     "authors"
    t.text     "abstract"
    t.string   "ref"
    t.string   "doi"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rcs", :force => true do |t|
    t.string  "token"
    t.string  "text"
    t.integer "ref_id"
  end

  add_index "rcs", ["token"], :name => "index_rcs_on_token"

  create_table "refs", :force => true do |t|
    t.integer "protein_id"
    t.string  "title"
    t.string  "auther"
    t.string  "location"
  end

  add_index "refs", ["location"], :name => "index_refs_on_location"
  add_index "refs", ["protein_id"], :name => "index_refs_on_protein_id"

  create_table "rgs", :force => true do |t|
    t.string  "name"
    t.integer "ref_id"
  end

  add_index "rgs", ["name"], :name => "index_rgs_on_name"

  create_table "rps", :force => true do |t|
    t.string  "comment"
    t.integer "ref_id"
  end

  add_index "rps", ["comment"], :name => "index_rps_on_comment"

  create_table "rxs", :force => true do |t|
    t.string  "name"
    t.string  "identifier"
    t.integer "ref_id"
  end

  add_index "rxs", ["name"], :name => "index_rxs_on_name"

  create_table "searchnames", :force => true do |t|
    t.integer "protein_id"
    t.string  "name"
  end

  add_index "searchnames", ["name"], :name => "name"
  add_index "searchnames", ["protein_id"], :name => "protein_id"

  create_table "species", :force => true do |t|
    t.string "name"
    t.string "common_name"
  end

  add_index "species", ["common_name"], :name => "index_species_on_common_name", :unique => true
  add_index "species", ["name"], :name => "index_species_on_name", :unique => true

  create_table "terminusmodifications", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "nterm",       :default => false
    t.boolean  "cterm",       :default => false
    t.string   "subcell"
    t.string   "psimodid"
    t.boolean  "display",     :default => true
    t.integer  "kw_id"
    t.string   "ac"
  end

  add_index "terminusmodifications", ["ac"], :name => "index_terminusmodifications_on_ac"
  add_index "terminusmodifications", ["kw_id"], :name => "index_terminusmodifications_on_kw_id"
  add_index "terminusmodifications", ["name"], :name => "index_terminusmodifications_on_name"

  create_table "tissues", :force => true do |t|
    t.string   "tsid"
    t.string   "ac"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tissuesynonymes", :force => true do |t|
    t.string   "sy"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tissue_id"
  end

  add_index "tissuesynonymes", ["tissue_id"], :name => "index_tissuesynonymes_on_tissue_id"

  create_table "users", :force => true do |t|
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "email_address"
    t.boolean  "administrator",                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                   :default => "active"
    t.datetime "key_timestamp"
    t.string   "affiliation"
  end

  add_index "users", ["state"], :name => "index_users_on_state"

end
