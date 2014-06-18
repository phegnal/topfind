class Protein < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    ac             :string, :required, :unique, :index => true
    name           :string, :required, :unique, :index => true
    data_class     :string
    molecular_type :integer
    entry_type     :string
    dt_create      :string
    dt_sequence    :string
    dt_annotation  :string
    definition     :string
    sequence       :text
    mw             :integer
    crc64          :string
    aalen          :integer
    chromosome	   :string, :index => true
    band	         :string, :index => true
    meropsfamily   :string, :index => true
    meropssubfamily :string, :index => true
    meropscode     :string, :index => true
    status         enum_string('created','pruned','updated','unknown'), :default => 'unknown'
    timestamps
  end
  
  def to_param
    self.ac
  end
      
  
#UniProt Protein Entry related 
  belongs_to :species 
  has_many :acs, :dependent => :destroy, :uniq => true
  has_many :proteinnames, :dependent => :destroy, :uniq => true
  has_many :searchnames, :dependent => :destroy, :uniq => true
  has_one :gn, :include => [:loci, :synonyms, :orf_names], :dependent => :destroy
  has_and_belongs_to_many :oss,  :join_table => :oss_proteins, :uniq => true
  has_and_belongs_to_many :ocs, :uniq => true
  has_and_belongs_to_many :oxs, :join_table => :oxs_proteins, :uniq => true
  has_many :refs, :include => [:rxs, :rgs, :rps, :rcs], :dependent => :destroy, :uniq => true
  has_many :ccs, :dependent => :destroy, :uniq => true
  has_many :drs, :dependent => :destroy, :uniq => true
  has_and_belongs_to_many :kws, :uniq => true
  has_many :fts, :dependent => :destroy, :uniq => true  
  has_many :publications,  :accessible => true, :dependent => :destroy, :uniq => true

#Cleavage, Substrate, Inhibition related
  has_many :cleavages, :foreign_key => 'protease_id', :accessible => :true, :uniq => true
  has_many :substrates, :through => :cleavages, :uniq => true
  has_many :inverse_cleavages, :class_name => "Cleavage", :foreign_key => "substrate_id", :accessible => true
  has_many :proteases, :through => :inverse_cleavages, :uniq => true  
 
  has_many :inhibitions, :foreign_key => 'inhibited_protease_id', :uniq => true
  has_many :inhibitors, :through => :inhibitions, :uniq => true
  has_many :inverse_inhibitions, :class_name => "Inhibition", :foreign_key => "inhibitor_id"
  has_many :inhibited_proteases, :through => :inverse_inhibitions, :uniq => true 

  has_many :chains, :uniq => true
  has_many :cterms, :uniq => true
  has_many :nterms, :uniq => true
  
  has_many :isoforms, :uniq => true
  
  
  
  


  # def htmlsequence
    # self.sequence.gsub(/(.{5})/,'\1 ')
  # end

  def htmlsequence
    numbering = ''
    blocks = (self.sequence.length/10).to_i
    number=10
    blocks.times do |i|
      number = ((i+1)*10).to_s
      numbering = numbering.concat(' '*(10-number.length))
      numbering = numbering.concat(number)
    end
    numberstrings = numbering.to_s.scan(/.{1,59}./).map {|s| s.gsub(/(.{10})/,'\1 ')}
    seqstrings = self.sequence.scan(/.{1,59}./).map {|s| s.gsub(/(.{10})/,'\1 ')}
    numberstrings.zip(seqstrings).flatten.join('<br/>').gsub(/ /,'&nbsp;').html_safe
  end
  
  def recname
  	if self.proteinnames.first
  		return self.proteinnames.first.full
  	else 
    	return self.name
    end
  end
  
  def shortname
    self.name.split('_')[0] 
  end

  # def merid
    # mer = self.drs.db_name_is('MEROPS').first
    # mer ? mer.protein_name : false   
  # end 
  def merid
    mer = self.meropscode
  end   
  
  # def proteasefamily
  	# self.merid ? self.merid.split('.')[0] : false
  # end

  def proteasefamily
    self.meropsfamily
  end
  
 
  
  def meropslink  	
  	self.merid ? link = "http://merops.sanger.ac.uk/cgi-bin/pepsum?mid=#{self.merid}" : link = false
  	return link
  end
  
  # def species
    # self.oss.first.name
  # end
#   
  def isprotease
    if self.cleavages.empty?
      return false
    else
      return true
    end
  end
    
  def issubstrate
    if self.proteases.empty?
      return false
    else
      return true
    end
  end
  
  def isinhibitor
    if self.inhibitions.empty?
      return false
    else
      return true
    end
  end

  def isinhibited
    if self.inhibitors.empty?
      return false
    else
      return true
    end
  end 
  
  def domains
    @domainfeatures = ['DOMAIN','MOTIF','PEPTIDE','PROPEP','REGION','SIGNAL','INIT_MET','SITE','TRANSIT'] 
    @res = Array.new
    self.fts.each do |ft|
      @res << ft if @domainfeatures.include?(ft.name)
    end
    @res.sort! {|x,y| x.from.to_i <=> y.from.to_i}
    @res
  end 
    

  def active_features
    @domainfeatures = ['ACT_SITE','DNA_BIND','BINDING','CA_BIND','NP_BIND','METAL','ZN_FING'] 
    @res = Array.new
    self.fts.each do |ft|
      @res << ft if @domainfeatures.include?(ft.name)
    end
    @res.sort! {|x,y| x.from.to_i <=> y.from.to_i}
    @res
  end
  
  def var_features
    @domainfeatures = ['CONFLICT','MUTAGEN','NON_CONS','VARIANT','UNSURE','VAR_SEQ'] 
    @res = Array.new
    self.fts.each do |ft|
      @res << ft if @domainfeatures.include?(ft.name)
    end
    @res.sort! {|x,y| x.from.to_i <=> y.from.to_i}
    @res
  end  
  
  def mod_features
    @domainfeatures = ['LIPID','MOD_RES','NON_STD'] 
    @res = Array.new
    self.fts.each do |ft|
      @res << ft if @domainfeatures.include?(ft.name)
    end
    @res.sort! {|x,y| x.from.to_i <=> y.from.to_i}
    @res
  end
  
  def topo_features
    @domainfeatures = ['COILED','CROSSLNK','HELIX','INTRAMEM','REPEAT','STRAND','TOPO_DOM','TRANSMEM','TURN'] 
    @res = Array.new
    self.fts.each do |ft|
      @res << ft if @domainfeatures.include?(ft.name)
    end
    @res.sort! {|x,y| x.from.to_i <=> y.from.to_i}
    @res
  end
  

 
  # --- Permissions --- #

  def create_permitted?
    false
  end

  def update_permitted?
    false
  end

  def destroy_permitted?
    false
  end

  def view_permitted?(field)
    true
  end


    

end



#UniProt related classes 
class Proteinname < ActiveRecord::Base 
  belongs_to :protein
  
  def view_permitted?(field)
    true
  end  
end

class Searchname < ActiveRecord::Base
  belongs_to :protein
end

class Ac < ActiveRecord::Base
  belongs_to :protein
end

class De < ActiveRecord::Base
  belongs_to :protein
end

class Gn < ActiveRecord::Base
  has_many :synonyms,  :table_name => 'GnSynonym', :class_name => 'GnSynonym'
  has_many :loci,      :table_name => 'GnLocus',   :class_name => 'GnLocus'
  has_many :orf_names, :table_name => 'GnOrfName', :class_name => 'GnOrfName'
end

class GnSynonym < ActiveRecord::Base
  belongs_to :gn
end

class GnLocus < ActiveRecord::Base
  set_table_name "gn_loci"
  belongs_to :gn
end

class GnOrfName < ActiveRecord::Base
  belongs_to :gn
end



class Os < ActiveRecord::Base
  set_table_name "oss"
  has_and_belongs_to_many :proteins, :join_table => :oss_proteins, :uniq => true
  
  def view_permitted?(field)
    true
  end  
end

class Oc < ActiveRecord::Base
  has_and_belongs_to_many :proteins
  
  def view_permitted?(field)
    true
  end  
end

class Ox < ActiveRecord::Base
  set_table_name "oxs"
  has_and_belongs_to_many :proteins, :join_table => :proteins_oxs
  
  def view_permitted?(field)
    true
  end  
end

class Ref < ActiveRecord::Base
  belongs_to :protein
  has_many :rxs
  has_many :rps
  has_many :rcs
  has_many :rgs
end

class Rx < ActiveRecord::Base
  set_table_name 'rxs'
  belongs_to :ref
end

class Rg < ActiveRecord::Base
  belongs_to :ref
end

class Rp < ActiveRecord::Base
  belongs_to :ref
end

class Rc < ActiveRecord::Base
  belongs_to :ref
  
  def view_permitted?(field)
    true
  end  
end

class Cc < ActiveRecord::Base
  belongs_to :protein
  
  named_scope :main, :conditions => "`topic` = 'CATALYTIC ACTIVITY' OR `topic` = 'DISEASE' OR `topic` = 'FUNCTION' OR `topic` = 'SUBCELLULAR LOCATION' = `topic` = 'TISSUE SPECIFICITY'"
  named_scope :additional, :conditions => "`topic` != 'ALLERGEN' AND `topic` != 'ALTERNATIVE PRODUCTS' AND `topic` != 'BIOPHYSICOCHEMICAL PROPERTIES' AND `topic`!= 'BIOTECHNOLOGY' AND `topic` != 'DISEASE' AND `topic` != 'INTERACTION' AND `topic` != 'FUNCTION' AND `topic` != 'MASS SPECTROMETRY' AND `topic` != 'PHARMACEUTICAL' AND `topic` != 'RNA EDITING' AND `topic` != 'SUBCELLULAR LOCATION' AND `topic` != 'TISSUE SPECIFICITY' AND `topic` != 'WEB RESOURCE'"
end

class Dr < ActiveRecord::Base
  hobo_model # Don't put anything above this  
  belongs_to :protein
  
  def view_permitted?(field)
    true
  end  
end

class Kw < ActiveRecord::Base
  hobo_model
  fields do
    name           :string, :required, :unique, :index => true  
    ac             :string, :index => true
    description	   :text
    category	   :string, :index => true
  end
  
  has_and_belongs_to_many :proteins
  has_many :terminusmodifications
  has_many :kwsynonymes
end

class Kwsynonyme < ActiveRecord::Base
  hobo_model
  fields do
    name           :string, :required, :unique, :index => true  
  end
  
  belongs_to :kw
end


class Ft < ActiveRecord::Base
  hobo_model
  belongs_to :protein
  has_many :chains, :through => :protein
  
  named_scope :present, lambda { |from,to|
    {:conditions => ['`from` >= ? AND `to` <= ?',from,to] }
  }
  named_scope :absent, lambda { |from,to|
    {:conditions => ['(`to` < ? ) OR ( `from` > ?)',from,to] }
  }
  
  named_scope :before, lambda { |pos|
    {:conditions => ['(`to` <= ? )' ,pos] }
  }
  
  named_scope :after, lambda { |pos|
    {:conditions => ['( `from` > ?)',pos] }
  }    
  
  named_scope :spanning, lambda { |from,to|
    {:conditions => ['(`from` <= ? ) AND ( `to` >= ?)',from,to] }
  }
  
  named_scope :matching, lambda { |pos|
    {:conditions => ['(`from` = ? ) OR ( `to` = ?)',pos,pos-1] }
  }
  
  named_scope :matchfrom, lambda { |pos|
    {:conditions => ['(`from` = ? )', pos] }
  }
  
  named_scope :matchto, lambda { |pos|
    {:conditions => ['(`to` = ? )', pos] }
  }  
  
  
  def view_permitted?(field)
    true
  end    
end
