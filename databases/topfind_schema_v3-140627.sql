-- phpMyAdmin SQL Dump
-- version 3.2.4
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jun 27, 2014 at 11:14 AM
-- Server version: 5.0.92
-- PHP Version: 5.3.26

--
-- TopFIND_skeleton from version v2-130522
--
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `topfind_production_130522`
--

-- --------------------------------------------------------

--
-- Table structure for table `acs`
--
-- Creation: May 22, 2013 at 01:04 PM
--

CREATE TABLE IF NOT EXISTS `acs` (
  `id` int(11) NOT NULL auto_increment,
  `protein_id` varchar(255) collate utf8_unicode_ci default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_acs_on_name` (`name`),
  KEY `index_acs_on_protein_id` (`protein_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ccs`
--
-- Creation: May 22, 2013 at 01:04 PM
--

CREATE TABLE IF NOT EXISTS `ccs` (
  `id` int(11) NOT NULL auto_increment,
  `topic` varchar(255) collate utf8_unicode_ci default NULL,
  `contents` text collate utf8_unicode_ci,
  `protein_id` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_ccs_on_protein_id` (`protein_id`),
  KEY `index_ccs_on_topic` (`topic`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chain2evidences`
--
-- Creation: May 22, 2013 at 01:04 PM
--

CREATE TABLE IF NOT EXISTS `chain2evidences` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `evidence_id` int(11) default NULL,
  `chain_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_chain2evidences_on_chain_id` (`chain_id`),
  KEY `index_chain2evidences_on_evidence_id` (`evidence_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chains`
--
-- Creation: May 22, 2013 at 01:04 PM
--

CREATE TABLE IF NOT EXISTS `chains` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `description` text collate utf8_unicode_ci,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `protein_id` int(11) default NULL,
  `cterm_id` int(11) default NULL,
  `nterm_id` int(11) default NULL,
  `isoform_id` int(11) default NULL,
  `idstring` varchar(255) collate utf8_unicode_ci default NULL,
  `from` int(11) default NULL,
  `to` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_chains_on_cterm_id` (`cterm_id`),
  KEY `index_chains_on_isoform_id` (`isoform_id`),
  KEY `index_chains_on_nterm_id` (`nterm_id`),
  KEY `index_chains_on_protein_id` (`protein_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cleavage2evidences`
--
-- Creation: May 22, 2013 at 01:04 PM
--

CREATE TABLE IF NOT EXISTS `cleavage2evidences` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `evidence_id` int(11) default NULL,
  `cleavage_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_cleavage2evidences_on_cleavage_id` (`cleavage_id`),
  KEY `index_cleavage2evidences_on_evidence_id` (`evidence_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cleavages`
--
-- Creation: May 22, 2013 at 01:04 PM
--

CREATE TABLE IF NOT EXISTS `cleavages` (
  `id` int(11) NOT NULL auto_increment,
  `protease_id` int(11) default NULL,
  `substrate_id` int(11) default NULL,
  `import_id` int(11) default NULL,
  `pos` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `cterm_id` int(11) default NULL,
  `nterm_id` int(11) default NULL,
  `cleavagesite_id` int(11) default NULL,
  `proteaseisoform_id` int(11) default NULL,
  `proteasechain_id` int(11) default NULL,
  `substrateisoform_id` int(11) default NULL,
  `substratechain_id` int(11) default NULL,
  `idstring` varchar(255) collate utf8_unicode_ci default NULL,
  `peptide` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_cleavages_on_cleavagesite_id` (`cleavagesite_id`),
  KEY `index_cleavages_on_cterm_id` (`cterm_id`),
  KEY `index_cleavages_on_import_id` (`import_id`),
  KEY `index_cleavages_on_nterm_id` (`nterm_id`),
  KEY `index_cleavages_on_protease_id` (`protease_id`),
  KEY `index_cleavages_on_proteasechain_id` (`proteasechain_id`),
  KEY `index_cleavages_on_proteaseisoform_id` (`proteaseisoform_id`),
  KEY `index_cleavages_on_substrate_id` (`substrate_id`),
  KEY `index_cleavages_on_substratechain_id` (`substratechain_id`),
  KEY `index_cleavages_on_substateisoform_id` (`substrateisoform_id`),
  KEY `index_cleavages_on_substrateisoform_id` (`substrateisoform_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cleavagesites`
--
-- Creation: May 22, 2013 at 01:04 PM
--

CREATE TABLE IF NOT EXISTS `cleavagesites` (
  `id` int(11) NOT NULL auto_increment,
  `p10` varchar(255) collate utf8_unicode_ci default '',
  `p9` varchar(255) collate utf8_unicode_ci default '',
  `p8` varchar(255) collate utf8_unicode_ci default '',
  `p7` varchar(255) collate utf8_unicode_ci default '',
  `p6` varchar(255) collate utf8_unicode_ci default '',
  `p5` varchar(255) collate utf8_unicode_ci default '',
  `p4` varchar(255) collate utf8_unicode_ci default '',
  `p3` varchar(255) collate utf8_unicode_ci default '',
  `p2` varchar(255) collate utf8_unicode_ci default '',
  `p1` varchar(255) collate utf8_unicode_ci default '',
  `p1p` varchar(255) collate utf8_unicode_ci default '',
  `p2p` varchar(255) collate utf8_unicode_ci default '',
  `p3p` varchar(255) collate utf8_unicode_ci default '',
  `p4p` varchar(255) collate utf8_unicode_ci default '',
  `p5p` varchar(255) collate utf8_unicode_ci default '',
  `p6p` varchar(255) collate utf8_unicode_ci default '',
  `p7p` varchar(255) collate utf8_unicode_ci default '',
  `p8p` varchar(255) collate utf8_unicode_ci default '',
  `p9p` varchar(255) collate utf8_unicode_ci default '',
  `p10p` varchar(255) collate utf8_unicode_ci default '',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `import_id` int(11) default NULL,
  `idstring` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_cleavagesites_on_import_id` (`import_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------


--
-- Table structure for table `cterm2evidences`
--
-- Creation: May 22, 2013 at 01:04 PM
--

CREATE TABLE IF NOT EXISTS `cterm2evidences` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `evidence_id` int(11) default NULL,
  `cterm_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_cterm2evidences_on_cterm_id` (`cterm_id`),
  KEY `index_cterm2evidences_on_evidence_id` (`evidence_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cterms`
--
-- Creation: May 22, 2013 at 01:04 PM
--

CREATE TABLE IF NOT EXISTS `cterms` (
  `id` int(11) NOT NULL auto_increment,
  `protein_id` int(11) default NULL,
  `pos` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `import_id` int(11) default NULL,
  `idstring` varchar(255) collate utf8_unicode_ci default NULL,
  `isoform_id` int(11) default NULL,
  `terminusmodification_id` int(11) default NULL,
  `seqexcerpt` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_cterms_on_import_id` (`import_id`),
  KEY `index_cterms_on_isoform_id` (`isoform_id`),
  KEY `index_cterms_on_protein_id` (`protein_id`),
  KEY `index_cterms_on_terminusmodification_id` (`terminusmodification_id`),
  KEY `true` (`seqexcerpt`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delayed_jobs`
--
-- Creation: May 22, 2013 at 01:04 PM
--

CREATE TABLE IF NOT EXISTS `delayed_jobs` (
  `id` int(11) NOT NULL auto_increment,
  `priority` int(11) default '0',
  `attempts` int(11) default '0',
  `handler` text collate utf8_unicode_ci,
  `last_error` text collate utf8_unicode_ci,
  `run_at` datetime default NULL,
  `locked_at` datetime default NULL,
  `failed_at` datetime default NULL,
  `locked_by` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `documentations`
--
-- Creation: May 22, 2013 at 01:04 PM
--

CREATE TABLE IF NOT EXISTS `documentations` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `title` varchar(255) collate utf8_unicode_ci default NULL,
  `long` text collate utf8_unicode_ci,
  `short` text collate utf8_unicode_ci,
  `category` varchar(255) collate utf8_unicode_ci default NULL,
  `position` int(11) default '0',
  `show` tinyint(1) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `drs`
--
-- Creation: May 22, 2013 at 01:04 PM
--

CREATE TABLE IF NOT EXISTS `drs` (
  `id` int(11) NOT NULL auto_increment,
  `protein_id` varchar(255) collate utf8_unicode_ci default NULL,
  `db_name` varchar(255) collate utf8_unicode_ci default NULL,
  `protein_name` varchar(255) collate utf8_unicode_ci default NULL,
  `content1` varchar(255) collate utf8_unicode_ci default NULL,
  `content2` varchar(255) collate utf8_unicode_ci default NULL,
  `content3` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_drs_on_db_name` (`db_name`),
  KEY `index_drs_on_protein_id` (`protein_id`),
  KEY `index_drs_on_protein_name` (`protein_name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `evidence2evidencecodes`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `evidence2evidencecodes` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `evidence_id` int(11) default NULL,
  `code` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_evidence2evidencecodes_on_code` (`code`),
  KEY `index_evidence2evidencecodes_on_evidence_id` (`evidence_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `evidence2gocomponents`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `evidence2gocomponents` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `evidence_id` int(11) default NULL,
  `gocomponent_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_evidence2gocomponents_on_evidence_id` (`evidence_id`),
  KEY `index_evidence2gocomponents_on_gocomponent_id` (`gocomponent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `evidence2publications`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `evidence2publications` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `evidence_id` int(11) default NULL,
  `publication_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_evidence2publications_on_evidence_id` (`evidence_id`),
  KEY `index_evidence2publications_on_publication_id` (`publication_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `evidence2tissues`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `evidence2tissues` (
  `id` int(11) NOT NULL auto_increment,
  `tissue_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `evidence_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_evidence2tissues_on_evidence_id` (`evidence_id`),
  KEY `index_evidence2tissues_on_tissue_id` (`tissue_id`),
  KEY `index_trace2tissues_on_tissue_id` (`tissue_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `evidencecodes`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `evidencecodes` (
  `id` int(11) NOT NULL auto_increment,
  `code` varchar(255) collate utf8_unicode_ci default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `definition` text collate utf8_unicode_ci,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `evidencerelations`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `evidencerelations` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `evidence_id` int(11) default NULL,
  `traceable_id` int(11) default NULL,
  `traceable_type` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_evidencerelations_on_evidence_id` (`evidence_id`),
  KEY `index_evidencerelations_on_traceables_type_and_traceables_id` (`traceable_id`),
  KEY `index_evidencerelations_on_traceable_type_and_traceable_id` (`traceable_type`,`traceable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `evidences`
--
-- Creation: May 29, 2013 at 12:14 PM
--

CREATE TABLE IF NOT EXISTS `evidences` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `method` varchar(255) collate utf8_unicode_ci default NULL,
  `protease_inhibitors_used` varchar(255) collate utf8_unicode_ci default NULL,
  `description` text collate utf8_unicode_ci,
  `phys_relevance` varchar(255) collate utf8_unicode_ci default 'unknown',
  `directness` varchar(255) collate utf8_unicode_ci default 'unknown',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `evidencefile_file_name` varchar(255) collate utf8_unicode_ci default NULL,
  `evidencefile_content_type` varchar(255) collate utf8_unicode_ci default NULL,
  `evidencefile_file_size` int(11) default NULL,
  `evidencefile_updated_at` datetime default NULL,
  `owner_id` int(11) default NULL,
  `idstring` varchar(255) collate utf8_unicode_ci default NULL,
  `repository` varchar(255) collate utf8_unicode_ci default NULL,
  `lab` varchar(255) collate utf8_unicode_ci default NULL,
  `evidencesource_id` int(11) default NULL,
  `confidence` float default NULL,
  `confidence_type` varchar(255) collate utf8_unicode_ci default 'unknown',
  `method_system` varchar(255) collate utf8_unicode_ci default 'unknown',
  `method_perturbation` varchar(255) collate utf8_unicode_ci default 'none',
  `method_protease_source` varchar(255) collate utf8_unicode_ci default 'unknown',
  `methodology` varchar(255) collate utf8_unicode_ci default 'unknown',
  `proteaseassignment_confidence` varchar(255) collate utf8_unicode_ci default 'unknown',
  PRIMARY KEY  (`id`),
  KEY `index_evidences_on_directness` (`directness`),
  KEY `index_evidences_on_evidencesource_id` (`evidencesource_id`),
  KEY `index_evidences_on_lab` (`lab`),
  KEY `index_evidences_on_method` (`method`),
  KEY `index_evidences_on_name` (`name`),
  KEY `index_evidences_on_owner_id` (`owner_id`),
  KEY `index_evidences_on_phys_relevance` (`phys_relevance`),
  KEY `index_evidences_on_method_system` (`method_system`),
  KEY `index_evidences_on_method_protease_source` (`method_protease_source`),
  KEY `index_evidences_on_methodology` (`methodology`),
  KEY `index_evidences_on_proteaseassignment_confidence` (`proteaseassignment_confidence`),
  KEY `method_perturbation` (`method_perturbation`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `evidencesources`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `evidencesources` (
  `id` int(11) NOT NULL auto_increment,
  `dbid` varchar(255) collate utf8_unicode_ci default NULL,
  `dbname` varchar(255) collate utf8_unicode_ci default NULL,
  `dburl` varchar(255) collate utf8_unicode_ci default NULL,
  `dbdesc` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fts`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `fts` (
  `id` int(11) NOT NULL auto_increment,
  `protein_id` varchar(255) collate utf8_unicode_ci default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `from` varchar(255) collate utf8_unicode_ci default NULL,
  `to` varchar(255) collate utf8_unicode_ci default NULL,
  `description` varchar(255) collate utf8_unicode_ci default NULL,
  `ftid` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_fts_on_ftid` (`ftid`),
  KEY `index_fts_on_name` (`name`),
  KEY `index_fts_on_protein_id` (`protein_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gns`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `gns` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `protein_id` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_gns_on_name` (`name`),
  KEY `index_gns_on_protein_id` (`protein_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gn_loci`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `gn_loci` (
  `id` int(11) NOT NULL auto_increment,
  `gn_id` int(11) default NULL,
  `locus` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_gn_loci_on_gn_id` (`gn_id`),
  KEY `index_gn_loci_on_locus` (`locus`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gn_orf_names`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `gn_orf_names` (
  `id` int(11) NOT NULL auto_increment,
  `gn_id` int(11) default NULL,
  `name` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_gn_orf_names_on_gn_id` (`gn_id`),
  KEY `index_gn_orf_names_on_name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gn_synonyms`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `gn_synonyms` (
  `id` int(11) NOT NULL auto_increment,
  `gn_id` int(11) default NULL,
  `synonym` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_gn_synonyms_on_gn_id` (`gn_id`),
  KEY `index_gn_synonyms_on_synonym` (`synonym`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gocomponents`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `gocomponents` (
  `id` int(11) NOT NULL auto_increment,
  `acc` varchar(255) collate utf8_unicode_ci default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `description` text collate utf8_unicode_ci,
  `is_obsolete` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gofunctionlinks`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `gofunctionlinks` (
  `id` int(11) NOT NULL auto_increment,
  `direct` tinyint(1) default NULL,
  `count` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `descendant_id` int(11) default NULL,
  `ancestor_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_gofunctionlinks_on_ancestor_id` (`ancestor_id`),
  KEY `index_gofunctionlinks_on_descendant_id` (`descendant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gofunctions`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `gofunctions` (
  `id` int(11) NOT NULL auto_increment,
  `acc` varchar(255) collate utf8_unicode_ci default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `description` text collate utf8_unicode_ci,
  `is_obsolete` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `golinks`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `golinks` (
  `id` int(11) NOT NULL auto_increment,
  `direct` tinyint(1) default NULL,
  `count` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `descendant_type` varchar(255) collate utf8_unicode_ci default NULL,
  `ancestor_type` varchar(255) collate utf8_unicode_ci default NULL,
  `descendant_id` int(11) default NULL,
  `ancestor_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_golinks_on_ancestor_type_and_ancestor_id` (`ancestor_type`,`ancestor_id`),
  KEY `index_golinks_on_descendant_type_and_descendant_id` (`descendant_type`,`descendant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `goprocesses`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `goprocesses` (
  `id` int(11) NOT NULL auto_increment,
  `acc` varchar(255) collate utf8_unicode_ci default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `description` text collate utf8_unicode_ci,
  `is_obsolete` tinyint(1) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `imports`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `imports` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `description` text collate utf8_unicode_ci,
  `inhibitions_listed` int(11) default '0',
  `inhibitions_imported` int(11) default '0',
  `cleavages_listed` int(11) default '0',
  `cleavages_imported` int(11) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `csvfile_file_name` varchar(255) collate utf8_unicode_ci default NULL,
  `csvfile_content_type` varchar(255) collate utf8_unicode_ci default NULL,
  `csvfile_file_size` int(11) default NULL,
  `csvfile_updated_at` datetime default NULL,
  `cterms_listed` int(11) default '0',
  `cterms_imported` int(11) default '0',
  `nterms_listed` int(11) default '0',
  `nterms_imported` int(11) default '0',
  `owner_id` int(11) default NULL,
  `evidence_id` int(11) default NULL,
  `datatype` varchar(255) collate utf8_unicode_ci default NULL,
  `cleavagesites_listed` int(11) default '0',
  `cleavagesites_imported` int(11) default '0',
  PRIMARY KEY  (`id`),
  KEY `index_imports_on_evidence_id` (`evidence_id`),
  KEY `index_imports_on_owner_id` (`owner_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inhibition2evidences`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `inhibition2evidences` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `evidence_id` int(11) default NULL,
  `inhibition_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_inhibition2evidences_on_evidence_id` (`evidence_id`),
  KEY `index_inhibition2evidences_on_inhibition_id` (`inhibition_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inhibitions`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `inhibitions` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `inhibitor_id` int(11) default NULL,
  `molecule_id` int(11) default NULL,
  `inhibitory_molecule_id` int(11) default NULL,
  `inhibited_proteaseisoform_id` int(11) default NULL,
  `inhibited_proteasechain_id` int(11) default NULL,
  `inhibitorisoform_id` int(11) default NULL,
  `inhibitorchain_id` int(11) default NULL,
  `inhibited_protease_id` int(11) default NULL,
  `idstring` varchar(255) collate utf8_unicode_ci default NULL,
  `import_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_inhibitions_on_import_id` (`import_id`),
  KEY `index_inhibitions_on_inhibited_protease_id` (`inhibited_protease_id`),
  KEY `index_inhibitions_on_inhibited_proteasechain_id` (`inhibited_proteasechain_id`),
  KEY `index_inhibitions_on_inhibited_proteaseisoform_id` (`inhibited_proteaseisoform_id`),
  KEY `index_inhibitions_on_inhibitor_id` (`inhibitor_id`),
  KEY `index_inhibitions_on_inhibitorchain_id` (`inhibitorchain_id`),
  KEY `index_inhibitions_on_inhibitorisoform_id` (`inhibitorisoform_id`),
  KEY `index_inhibitions_on_inhibitory_molecule_id` (`inhibitory_molecule_id`),
  KEY `index_inhibitions_on_molecule_id` (`molecule_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `isoforms`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `isoforms` (
  `id` int(11) NOT NULL auto_increment,
  `ac` varchar(255) collate utf8_unicode_ci default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `sequence` text collate utf8_unicode_ci,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `protein_id` int(11) default NULL,
  `status` varchar(255) collate utf8_unicode_ci default 'unknown',
  PRIMARY KEY  (`id`),
  KEY `index_isoforms_on_protein_id` (`protein_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kws`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `kws` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `ac` varchar(255) collate utf8_unicode_ci default NULL,
  `description` text collate utf8_unicode_ci,
  `category` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_kws_on_ac` (`ac`),
  KEY `index_kws_on_category` (`category`),
  KEY `index_kws_on_name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kwsynonymes`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `kwsynonymes` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `kw_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_kwsynonymes_on_name` (`name`),
  KEY `index_kwsynonymes_on_kw_id` (`kw_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kws_proteins`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `kws_proteins` (
  `protein_id` int(11) default NULL,
  `kw_id` int(11) default NULL,
  KEY `index_kws_proteins_on_kw_id` (`kw_id`),
  KEY `index_kws_proteins_on_protein_id` (`protein_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `moleculenames`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `moleculenames` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `molecule_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_moleculenames_on_molecule_id` (`molecule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `molecules`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `molecules` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `description` text collate utf8_unicode_ci,
  `formula` varchar(255) collate utf8_unicode_ci default NULL,
  `external_id` varchar(255) collate utf8_unicode_ci default NULL,
  `source` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `nterm2evidences`
--
-- Creation: May 22, 2013 at 01:06 PM
--

CREATE TABLE IF NOT EXISTS `nterm2evidences` (
  `id` int(11) NOT NULL auto_increment,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `evidence_id` int(11) default NULL,
  `nterm_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_nterm2evidences_on_evidence_id` (`evidence_id`),
  KEY `index_nterm2evidences_on_nterm_id` (`nterm_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `nterms`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `nterms` (
  `id` int(11) NOT NULL auto_increment,
  `protein_id` int(11) default NULL,
  `pos` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `import_id` int(11) default NULL,
  `idstring` varchar(255) collate utf8_unicode_ci default NULL,
  `isoform_id` int(11) default NULL,
  `terminusmodification_id` int(11) default NULL,
  `seqexcerpt` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_nterms_on_import_id` (`import_id`),
  KEY `index_nterms_on_isoform_id` (`isoform_id`),
  KEY `index_nterms_on_protein_id` (`protein_id`),
  KEY `index_nterms_on_terminusmodification_id` (`terminusmodification_id`),
  KEY `true` (`seqexcerpt`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ocs`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `ocs` (
  `id` int(11) NOT NULL auto_increment,
  `level` int(11) default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_ocs_on_name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ocs_proteins`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `ocs_proteins` (
  `protein_id` int(11) default NULL,
  `oc_id` int(11) default NULL,
  KEY `index_ocs_proteins_on_oc_id` (`oc_id`),
  KEY `index_ocs_proteins_on_protein_id` (`protein_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `oss`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `oss` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `common_name` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_oss_on_name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `oss_proteins`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `oss_proteins` (
  `protein_id` int(11) default NULL,
  `os_id` int(11) default NULL,
  KEY `index_oss_proteins_on_os_id` (`os_id`),
  KEY `index_oss_proteins_on_protein_id` (`protein_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `oxs`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `oxs` (
  `id` int(11) NOT NULL auto_increment,
  `db_name` varchar(255) collate utf8_unicode_ci default NULL,
  `accession` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_oxs_on_accession` (`accession`),
  KEY `index_oxs_on_db_name` (`db_name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `oxs_proteins`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `oxs_proteins` (
  `protein_id` int(11) default NULL,
  `ox_id` int(11) default NULL,
  KEY `index_oxs_proteins_on_ox_id` (`ox_id`),
  KEY `index_oxs_proteins_on_protein_id` (`protein_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `proteinnames`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `proteinnames` (
  `id` int(11) NOT NULL auto_increment,
  `protein_id` varchar(255) collate utf8_unicode_ci default NULL,
  `full` varchar(255) collate utf8_unicode_ci default NULL,
  `short` varchar(255) collate utf8_unicode_ci default NULL,
  `recommended` tinyint(1) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_proteinnames_on_full` (`full`),
  KEY `index_proteinnames_on_protein_id` (`protein_id`),
  KEY `index_proteinnames_on_short` (`short`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `proteins`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `proteins` (
  `id` int(11) NOT NULL auto_increment,
  `ac` varchar(255) collate utf8_unicode_ci default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `molecular_type` int(11) default NULL,
  `entry_type` varchar(255) collate utf8_unicode_ci default NULL,
  `dt_create` varchar(255) collate utf8_unicode_ci default NULL,
  `dt_sequence` varchar(255) collate utf8_unicode_ci default NULL,
  `dt_annotation` varchar(255) collate utf8_unicode_ci default NULL,
  `definition` varchar(255) collate utf8_unicode_ci default NULL,
  `sequence` text collate utf8_unicode_ci,
  `mw` int(11) default NULL,
  `crc64` varchar(255) collate utf8_unicode_ci default NULL,
  `aalen` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `status` varchar(255) collate utf8_unicode_ci default 'unknown',
  `data_class` varchar(255) collate utf8_unicode_ci default NULL,
  `chromosome` varchar(255) collate utf8_unicode_ci default NULL,
  `band` varchar(255) collate utf8_unicode_ci default NULL,
  `species_id` int(11) default NULL,
  `meropsfamily` varchar(255) collate utf8_unicode_ci default NULL,
  `meropssubfamily` varchar(255) collate utf8_unicode_ci default NULL,
  `meropscode` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_proteins_on_ac` (`ac`),
  UNIQUE KEY `index_proteins_on_name` (`name`),
  KEY `index_proteins_on_species_id` (`species_id`),
  KEY `index_proteins_on_chromosome` (`chromosome`),
  KEY `index_proteins_on_band` (`band`),
  KEY `index_proteins_on_meropssubfamily` (`meropssubfamily`),
  KEY `index_proteins_on_meropscode` (`meropscode`),
  KEY `meropsfamily` (`meropsfamily`),
  KEY `index_proteins_on_meropsfamily` (`meropsfamily`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `proteins_oss`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `proteins_oss` (
  `os_id` int(11) default NULL,
  `protein_id` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `proteins_oxs`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `proteins_oxs` (
  `ox_id` int(11) default NULL,
  `protein_id` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `publications`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `publications` (
  `id` int(11) NOT NULL auto_increment,
  `pmid` int(11) default NULL,
  `title` varchar(255) collate utf8_unicode_ci default NULL,
  `authors` text collate utf8_unicode_ci,
  `abstract` text collate utf8_unicode_ci,
  `ref` varchar(255) collate utf8_unicode_ci default NULL,
  `doi` varchar(255) collate utf8_unicode_ci default NULL,
  `url` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rcs`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `rcs` (
  `id` int(11) NOT NULL auto_increment,
  `token` varchar(255) collate utf8_unicode_ci default NULL,
  `text` varchar(255) collate utf8_unicode_ci default NULL,
  `ref_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_rcs_on_token` (`token`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `refs`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `refs` (
  `id` int(11) NOT NULL auto_increment,
  `protein_id` int(11) default NULL,
  `title` varchar(255) collate utf8_unicode_ci default NULL,
  `auther` varchar(255) collate utf8_unicode_ci default NULL,
  `location` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_refs_on_location` (`location`),
  KEY `index_refs_on_protein_id` (`protein_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rgs`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `rgs` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `ref_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_rgs_on_name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rps`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `rps` (
  `id` int(11) NOT NULL auto_increment,
  `comment` varchar(255) collate utf8_unicode_ci default NULL,
  `ref_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_rps_on_comment` (`comment`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rxs`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `rxs` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `identifier` varchar(255) collate utf8_unicode_ci default NULL,
  `ref_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_rxs_on_name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schema_migrations`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `schema_migrations` (
  `version` varchar(255) collate utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `searchnames`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `searchnames` (
  `id` int(11) NOT NULL auto_increment,
  `protein_id` int(11) default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `name` (`name`),
  KEY `protein_id` (`protein_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `species`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `species` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `common_name` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_species_on_name` (`name`),
  UNIQUE KEY `index_species_on_common_name` (`common_name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `terminusmodifications`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `terminusmodifications` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `description` text collate utf8_unicode_ci,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `nterm` tinyint(1) default '0',
  `cterm` tinyint(1) default '0',
  `subcell` varchar(255) collate utf8_unicode_ci default NULL,
  `psimodid` varchar(255) collate utf8_unicode_ci default NULL,
  `display` tinyint(1) default '1',
  `kw_id` int(11) default NULL,
  `ac` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_terminusmodifications_on_ac` (`ac`),
  KEY `index_terminusmodifications_on_kw_id` (`kw_id`),
  KEY `index_terminusmodifications_on_name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tissues`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `tissues` (
  `id` int(11) NOT NULL auto_increment,
  `tsid` varchar(255) collate utf8_unicode_ci default NULL,
  `ac` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tissuesynonymes`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `tissuesynonymes` (
  `id` int(11) NOT NULL auto_increment,
  `sy` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `tissue_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_tissuesynonymes_on_tissue_id` (`tissue_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--
-- Creation: May 22, 2013 at 01:07 PM
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL auto_increment,
  `crypted_password` varchar(40) collate utf8_unicode_ci default NULL,
  `salt` varchar(40) collate utf8_unicode_ci default NULL,
  `remember_token` varchar(255) collate utf8_unicode_ci default NULL,
  `remember_token_expires_at` datetime default NULL,
  `name` varchar(255) collate utf8_unicode_ci default NULL,
  `email_address` varchar(255) collate utf8_unicode_ci default NULL,
  `administrator` tinyint(1) default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `state` varchar(255) collate utf8_unicode_ci default 'active',
  `key_timestamp` datetime default NULL,
  `affiliation` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`id`),
  KEY `index_users_on_state` (`state`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
