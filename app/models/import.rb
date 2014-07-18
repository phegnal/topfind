class Import < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string, :required => true
    description :text
    datatype enum_string('proteases cleaving a protein','proteases cleaving a peptide','proteases inhibited by protein inhibitors','N-termini','C-termini')
    inhibitions_listed :integer, :default => 0
    inhibitions_imported :integer, :default => 0
    cleavages_listed :integer, :default => 0
    cleavages_imported :integer, :default => 0
    cleavagesites_listed :integer, :default => 0
    cleavagesites_imported :integer, :default => 0     
    cterms_listed :integer, :default => 0
    cterms_imported :integer, :default => 0
    nterms_listed :integer, :default => 0
    nterms_imported :integer, :default => 0
       
    timestamps
  end

  has_many :cleavages, :dependent => :destroy
  has_many :cleavagesites, :dependent => :destroy
  has_many :inhibitions, :dependent => :destroy
  has_many :cterms, :dependent => :destroy
  has_many :nterms, :dependent => :destroy
  belongs_to :evidence, :accessible => true
  has_attached_file :csvfile
  
  belongs_to :owner, :class_name => "User", :creator => true

  
  
  def process_csv
    csvdata = FasterCSV.read(self.csvfile.path)
    # 
    headers = csvdata.shift.map {|i| i.to_s }
    # y headers
    string_data = csvdata.map {|row| row.map {|cell| cell.to_s } }
    csvhash = string_data.map {|row| Hash[*headers.zip(row).flatten] }
        
    case self.datatype
      when 'proteases cleaving a protein'
        import_cleavages(csvhash)
      when 'proteases cleaving a peptide'
        import_cleavagesites(csvhash)
      when 'proteases inhibited by protein inhibitors'
        import_inhibitions(csvhash)
      when 'C-termini'
        import_cterm(csvhash)
      when 'N-termini'
        import_nterm(csvhash)
    end 
  end
  
  def import_cleavages(csvhash)
  	puts 'import cleavages'
    csvhash.each do |csvrow|
      self.update_attributes(:cleavages_listed => self.cleavages_listed.next)       
      proteasestring = csvrow['protease'].split('-') 
      protease = Protein.find_by_ac(proteasestring[0])
      proteasestring[1] ? proteaseisoformid = Isoform.find_by_ac(csvrow['protease']).id : proteaseisoformid = nil
      substratestring = csvrow['substrate'].split('-') 
      substrate = Protein.find_by_ac(substratestring[0])
      substratestring[1] ? substrateisoformid = Isoform.find_by_ac(csvrow['substrate']).id : substrateisoformid = nil
      csvrow['position'].include?('-') ? pos = csvrow['position'].split('-')[0].to_i : pos = csvrow['position'].to_i
      

      if protease && substrate && self.evidence
        idstring = "P(#{protease.ac})->S(#{substrate.ac})at(#{pos})"
        newcleavage = Cleavage.find_or_create_by_idstring(
            :idstring => idstring,
            :protease_id => protease.id,
            :proteaseisoform_id => proteaseisoformid,
            :substrate_id => substrate.id,
            :substrateisoform_id => substrateisoformid,
            :pos => pos,
            :import_id => self.id
          )  
        newcleavage.evidences << self.evidence
        self.update_attributes(:cleavages_imported => self.cleavages_imported.next) 
        newcleavage.map_to_isoforms
      end     
    end
  end  
  
  def import_cleavagesites(csvhash)
  	puts 'import cleavagesites'
    csvhash.each do |csvrow|
      self.update_attributes(:cleavagesites_listed => self.cleavagesites_listed.next)       
      proteasestring = csvrow['protease'].split('-') 
      protease = Protein.find_by_ac(proteasestring[0])
      proteasestring[1] ? proteaseisoformid = Isoform.find_by_ac(csvrow['protease']).id : proteaseisoformid = nil
      peptide = csvrow['peptide']

      if protease && peptide && self.evidence
        idstring = "P(#{protease.ac})->Pep(#{peptide})"
        newcleavage = Cleavage.find_or_create_by_idstring(
            :idstring => idstring,
            :protease_id => protease.id,
            :proteaseisoform_id => proteaseisoformid,
            :peptide => peptide,
            :import_id => self.id
          )  
        newcleavage.evidences << self.evidence 
        self.update_attributes(:cleavages_imported => self.cleavages_imported.next) 
      end     
    end
  end 
      
  def import_inhibitions(csvhash)
  	puts 'import inhibitions'
    csvhash.each do |csvrow|
      self.update_attributes(:inhibitions_listed => self.inhibitions_listed.next)       
      proteasestring = csvrow['protease'].split('-') 
      protease = Protein.find_by_ac(proteasestring[0])
      proteasestring[1] ? proteaseisoformid = Isoform.find_by_ac(csvrow['protease']).id : proteaseisoformid = nil
      inhibitiorstring = csvrow['inhibitor'].split('-') 
      inhibitor = Protein.find_by_ac(inhibitorstring[0])
      inhibitorstring[1] ? inhibitorisoformid = Isoform.find_by_ac(csvrow['inhibitor']).id : inhibitorisoformid = nil
      

      puts "#{protease}-#{csvrow['protease']}  || #{substrate}-#{csvrow['substrate']}  || #{input[:evidence_id]}"
      if protease && substrate && self.evidence
        idstring = "I(#{inhibitor.ac})-|P(#{protease.ac})"
        newinhibition = Inhibition.find_or_create_by_idstring(
          :idstring => idstring,
          :inhibitor_id => inhibitor.id,
          :inhibitorisoform_id => inhibitorisformid,
          :inhibited_protease_id => protease.id,
          :inhibitredproteaseisoform_id => proteaseisoformid,
          :import_id => self.id
          )  
        newinhibition.evidences << self.evidence 
        self.update_attributes(:inhibitions_imported => self.inhibitions_imported.next) 
      end     
    end
  end 
  
  def import_cterm(csvhash)
  	puts 'import cterm'
    csvhash.each do |csvrow|
      self.update_attributes(:cterms_listed => self.cterms_listed.next)       
      proteinstring = csvrow['protein'].split('-') 
      protein = Protein.find_by_ac(proteinstring[0])
      proteinstring[1] ? proteinisoformid = Isoform.find_by_ac(csvrow['protein']).id : ptoteinisoformid = nil
      pos = csvrow['position']
      mod = csvrow['modification']
      termmod = Terminusmodification.name_or_ac_or_psimodid_is(mod).first
      termmod = Terminusmodification.kw_is(Kw.kwsynonymes_name_is(mod).first).first if termmod.nil?
      termmod = Terminusmodification.name_is('unknown').first if termmod.nil?
      confidence = csvrow['confidence']
      confidence_type = csvrow['confidence_type']
      
      if protein && pos && self.evidence
        ct_idstring = "#{protein.ac}-#{pos}-#{mod}"
        cterm = Cterm.find_or_create_by_idstring(
          :idstring => ct_idstring,  
          :protein => protein,
          :isoform_id => proteinisoformid,
          :pos => pos,
          :terminusmodification => termmod,
          :import_id => self.id)
        cterm.evidences << self.evidence
        #cterm.cterm2evidences.evidence_id_is(input[:evidence_id]).first.update_attributes(:confidence => confidence, :confidence_type => confidence_type) 
        self.update_attributes(:cterms_imported => self.cterms_imported.next)
        cterm.map_to_isoforms
      end 
    end    
  end
  
  def import_nterm(csvhash)
  	puts 'import nterm'
    csvhash.each do |csvrow|
      self.update_attributes(:nterms_listed => self.nterms_listed.next)
      proteinstring = csvrow['protein'].split('-') 
      protein = Protein.find_by_ac(proteinstring[0])
      proteinstring[1] ? proteinisoformid = Isoform.find_by_ac(csvrow['protein']).id : ptoteinisoformid = nil
      pos = csvrow['position']
      mod = csvrow['modification']
      termmod = Terminusmodification.name_or_ac_or_psimodid_is(mod).first
      termmod = Terminusmodification.kw_is(Kw.kwsynonymes_name_is(mod).first).first if termmod.nil?
      termmod = Terminusmodification.name_is('unknown').first if termmod.nil?
      confidence = csvrow['confidence']
      confidence_type = csvrow['confidence_type']
      
      if protein && pos && self.evidence
        nt_idstring = "#{protein.ac}-#{pos}-#{mod}"
        nterm = Nterm.find_or_create_by_idstring(
          :idstring => nt_idstring,
          :protein => protein,
          :isoform_id => proteinisoformid,
          :pos => pos,
          :terminusmodification => termmod,
          :import_id => self.id)  
        nterm.evidences << self.evidence 
        #nterm.nterm2evidences.evidence_id_is(input[:evidence_id]).first.update_attributes(:confidence => confidence, :confidence_type => confidence_type)
        self.update_attributes(:nterms_imported => self.nterms_imported.next)
        nterm.map_to_isoforms
      end 
    end 
  end
  
  # --- Permissions --- #

  def create_permitted?
    acting_user
  end

  def update_permitted?
    acting_user.administrator? && acting_user.name == 'plange-admin'
  end

  def destroy_permitted?
    acting_user.administrator? && acting_user.name == 'plange-admin'
  end

  def view_permitted?(field)
    true
  end

end
