class Merops < ActiveRecord::Base
  establish_connection :meropsweb
  set_table_name "code"

  has_many :mcleavages, :foreign_key => 'code'
  has_many :msubstrate_searchs, :foreign_key => 'code'
  has_many :msmis, :foreign_key => 'code'
  
  
end

class Msubstrate_search < ActiveRecord::Base
  establish_connection :meropsweb
  set_table_name "Substrate_search" 
  
  belongs_to :mcode
end

class Mcleavage < ActiveRecord::Base
  establish_connection :meropsweb
  set_table_name "cleavage"
  
  require 'nokogiri'
  require 'open-uri'
  
  
  belongs_to :mcode
  
  def mid    
    if self.Ref
      self.Ref.match(/\[(.*)\]/)[1] != ('' || nil) ? self.Ref.match(/\[(.*)\]/)[1] : nil
    else
      nil
    end
  end
  
  def reftext 
    self.Ref.match(/<%(.*)\[/)[1]
  end  
  
  def pmid
    if self.mid
      url = "http://merops.sanger.ac.uk/cgi-bin/refs?id=#{self.mid}"
      doc = Nokogiri::HTML(open(url))
      if doc.at_css('.pubmed')
        doc.at_css('.pubmed').to_s.match(/list_uids=(.*)?;/) ? doc.at_css('.pubmed').to_s.match(/list_uids=(.*)?;/)[1] : nil
      else
        nil
      end
    else 
      return nil
    end
  end
end

class Minhibition < ActiveRecord::Base
  establish_connection :meropsweb
  set_table_name "peptidase_inhibitor_complex"
  
  belongs_to :mcode
  
  def mid    
    if self.ref
      if self.ref.match(/\[(.*)\]/)
        self.ref.match(/\[(.*)\]/)[1] != ('' || nil) ? self.ref.match(/\[(.*)\]/)[1] : nil
      else
        nil
      end
    else
      nil
    end
  end
  
  
  def pmid
    if self.mid
      url = "http://merops.sanger.ac.uk/cgi-bin/refs?id=#{self.mid}"
      doc = Nokogiri::HTML(open(url))
      if doc.at_css('.pubmed')
        doc.at_css('.pubmed').to_s.match(/list_uids=(.*)?;/) ? doc.at_css('.pubmed').to_s.match(/list_uids=(.*)?;/)[1] : nil
      else
        nil
      end
    else 
      return nil
    end
  end  
end

class Msmi < ActiveRecord::Base
  establish_connection :meropsweb
  set_table_name "smi"
  
  belongs_to :mcode
  has_many :msminames, :foreign_key => 'code'
end

class Msminame < ActiveRecord::Base
  establish_connection :meropsweb
  set_table_name "smi_name"
  set_inheritance_column :ruby_type
  
 # getter for the "type" column
 def device_type
  self[:type]
 end

 # setter for the "type" column
 def device_type=(s)
  self[:type] = s
 end

  belongs_to :msmi
end