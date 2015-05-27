require File.dirname(__FILE__) + '/../test_helper'

class ProteinTest < ActiveSupport::TestCase
  fixtures :proteins
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_protein
  
     #testing protein creation
     sample_protein = Protein.new :name => proteins(:A1433E_HUMAN).name,
			    :ac => proteins(:A1433E_HUMAN).ac,
			    :molecular_type => proteins(:A1433E_HUMAN).molecular_type,
			    :entry_type => proteins(:A1433E_HUMAN).entry_type,
			    :dt_create => proteins(:A1433E_HUMAN).dt_create,
			    :dt_sequence => proteins(:A1433E_HUMAN).dt_sequence,
			    :dt_annotation => proteins(:A1433E_HUMAN).dt_annotation,
			    :definition => proteins(:A1433E_HUMAN).definition,
			    :sequence => proteins(:A1433E_HUMAN).sequence,
			    :mw => proteins(:A1433E_HUMAN).mw,
			    :crc64 => proteins(:A1433E_HUMAN).crc64,
			    :aalen => proteins(:A1433E_HUMAN).aalen,
			    :created_at => proteins(:A1433E_HUMAN).created_at,
			    :updated_at => proteins(:A1433E_HUMAN).updated_at,
			    :status => proteins(:A1433E_HUMAN).status,
			    :data_class => proteins(:A1433E_HUMAN).data_class,
			    :chromosome => proteins(:A1433E_HUMAN).chromosome,
			    :band => proteins(:A1433E_HUMAN).band,
			    :species_id => proteins(:A1433E_HUMAN).species_id,
			    :meropsfamily => proteins(:A1433E_HUMAN).meropsfamily,
			    :meropssubfamily => proteins(:A1433E_HUMAN).meropssubfamily,
			    :meropscode => proteins(:A1433E_HUMAN).meropscode

     
     assert sample_protein.name, "Protein does not have a name"
     assert sample_protein.ac, "Protein does not have an ac"
     assert !sample_protein.save, "Protein did not save"
     assert sample_protein.is_canonical, "The protein is not canoninical!"
     assert sample_protein.recname == "1433E_HUMAN", "recname is not correct"
     assert sample_protein.shortname == "1433E", "shortname is not correct"
     assert sample_protein.isprotease == false, "this is not protease"
     assert sample_protein.issubstrate == false, "this is not a substrate"
     assert sample_protein.isinhibitor == false, "this is not an inhibitor"
     
     #testing finding proteins domains function
     found_protein = Protein.find(1)
     puts found_protein.active_features.to_s
     assert found_protein.domains.to_s == "SIGNAL", "this is the wrong domain"
     assert found_protein.active_features.to_s == "ACT_SITE", "this is the wrong active feature"
     assert found_protein.var_features.to_s == "CONFLICT", "this is the wrong var feature"
     assert found_protein.mod_features.to_s == "LIPID", "this is the wrong mod feature"
     assert found_protein.topo_features.to_s == "COILED", "this is the wrong mod feature"
     assert found_protein.isoform_crossmapping(25,"centre").include?("P31946-2"), "this is missing a domain"
     
     #assert found_protein.isprotease == true, "this is not protease"
     #assert found_protein.issubstrate == true, "this is not a substrate"
     #assert found_protein.isinhibitor == true, "this is not an inhibitor"
    
     
     
  end
end
