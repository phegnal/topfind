class Analysis

  attr_accessor :protein, :cleavages, :cleavagesites, :inverse_cleavages, :inhibitions, :inverse_inhibitions, :nterms, :cterms,:filtered,:evidences, :ppi

  def initialize(protein, cleavages, cleavagesites, inverse_cleavages, inhibitions, inverse_inhibitions, cterms, nterms,filtered, evidences = [],ppi = false)
    @protein = protein
    @cleavages = cleavages
    @cleavagesites = cleavagesites
    @inverse_cleavages = inverse_cleavages
    @inhibitions = inhibitions
    @inverse_inhibitions= inverse_inhibitions
    @nterms = nterms
    @cterms = cterms
    @filtered = filtered
    @evidences = evidences
    @ppi = ppi
  end
  
  #---- graphs and images -----#
      # Create a new graph

  def graph
 
    
    @graphml = "<graphml><key id='label' for='all' attr.name='label' attr.type='string'/><key id='link' for='all' attr.name='link' attr.type='string'/><key id='weight' for='all' attr.name='weight' attr.type='double'/><key id='edgetype' for='edge' attr.name='edgetype' attr.type='string'/><key id='nodetype' for='node' attr.name='nodetype' attr.type='string'/><graph edgedefault='directed'>"  
    @sif = ''
    
    @max = 2
    @log = Array.new
    @additional = {'cleavage' => {}, 'inverse_cleavage' => {}, 'inhibition' => {}, 'inverse_inhibition' => {}, 'interaction' => {}}
    add_nodes(nil,self.protein,nil,0,nil)
    add_additional_nodes(@additional['cleavage'],'cleavage')
    add_additional_nodes(@additional['inverse_cleavage'],'inverse_cleavage')
    add_additional_nodes(@additional['inhibition'],'inhibition')
    add_additional_nodes(@additional['inverse_inhibition'],'inverse_inhibition')
    
    @graphml << "</graph></graphml>"

    
    # f = File.open("#{RAILS_ROOT}/public/images/dynamic/#{self.protein.name}-#{'ppi' if ppi}network.graphml", 'w')
    # f << @graphml
    # f.close

    return @graphml
  end
  
  def add_nodes(parent,protein,type,i,logstr)
    
    if parent 
      unless @log.include?(logstr)
        @log.push(logstr)
        n = protein.proteases.count + protein.inhibitors.count + protein.substrates.count
        pn = parent.proteases.count + parent.inhibitors.count + parent.substrates.count
        
        if ((n <= 0 && pn >= 2 ) && parent.id != self.protein.id)
          @additional[type].has_key?(parent.shortname) ? @additional[type][parent.shortname]+=1 : @additional[type][parent.shortname] = 1
          return ''
        else
          case type
            when 'cleavage'
              unless @log.include?("a#{protein.id}")
	              @graphml << "<node id='#{protein.shortname}'>"
	              @graphml << "<data key='label'>#{protein.recname}</data>"
	              @graphml << "<data key='link'>/topfind/proteins/#{protein.ac}</data>"
	        	  protein.isprotease ? @graphml << "<data key='nodetype'>protease</data>" : @graphml << "<data key='nodetype'>protein</data>"  
	              @graphml << "</node>"      
	      		  @log.push("a#{protein.id}")
      		  end 
              
              @graphml << "<edge source='#{parent.shortname}' target='#{protein.shortname}'>"
              @graphml << "<data key='label'>cleaves</data>"
              @graphml << "<data key='edgetype'>cleavage</data>"
	          @graphml << "<data key='link'>#{}</data>"
              @graphml << "</edge>"
                               
            when 'inverse_cleavage'
              unless @log.include?("a#{protein.id}")
	              @graphml << "<node id='#{protein.shortname}'>"
	              @graphml << "<data key='label'>#{protein.recname}</data>"
	              @graphml << "<data key='link'>/topfind/proteins/#{protein.ac}</data>"
	              protein.isprotease ? @graphml << "<data key='nodetype'>protease</data>" : @graphml << "<data key='nodetype'>protein</data>" 
	              @graphml << "</node>"   
	      		  @log.push("a#{protein.id}") 
              end
              
              @graphml << "<edge source='#{protein.shortname}' target='#{parent.shortname}'>"
              @graphml << "<data key='label'>cleaves</data>"
              @graphml << "<data key='edgetype'>cleavage</data>"
              @graphml << "</edge>"   
      		  @log.push("a#{protein.id}") 
              
            when 'inhibition'
              unless @log.include?("a#{protein.id}")
	              @graphml << "<node id='#{protein.shortname}'>"
	              @graphml << "<data key='label'>#{protein.recname}</data>"
	              @graphml << "<data key='link'>/topfind/proteins/#{protein.ac}</data>"
	              protein.isprotease ? @graphml << "<data key='nodetype'>protease</data>" : @graphml << "<data key='nodetype'>protein</data>" 
	              @graphml << "</node>"   
	      		  @log.push("a#{protein.id}") 
	          end
	              
              @graphml << "<edge source='#{protein.shortname}' target='#{parent.shortname}'>"
              @graphml << "<data key='label'>inhibits</data>"
              @graphml << "<data key='edgetype'>inhibition</data>"
              @graphml << "</edge>"
              
            when 'inverse_inhibiton'
              unless @log.include?("a#{protein.id}")
	              @graphml << "<node id='#{protein.shortname}'>"
	              @graphml << "<data key='label'>#{protein.recname}</data>"
	              @graphml << "<data key='link'>/topfind/proteins/#{protein.ac}</data>"
	              protein.isprotease ? @graphml << "<data key='nodetype'>protease</data>" : @graphml << "<data key='nodetype'>protein</data>" 
	              @graphml << "</node>"   
	      		  @log.push("a#{protein.id}") 
              end
              
              @graphml << "<edge source='#{parent.shortname}' target='#{protein.shortname}'>"
              @graphml << "<data key='label'>inhibits</data>"
              @graphml << "<data key='edgetype'>inhibition</data>"
              @graphml << "</edge>"
            
            when 'interaction' 
              unless @log.include?("#{protein.id}-#{parent.id}")
              	unless @log.include?("a#{protein.id}")
				  @graphml << "<node id='#{protein.shortname}'>"
				  @graphml << "<data key='label'>#{protein.recname}</data>"
	              @graphml << "<data key='link'>/topfind/proteins/#{protein.ac}</data>"
				  @graphml << "</node>"   
      		      @log.push("a#{protein.id}") 
      		    end
				  
				  @graphml << "<edge source='#{parent.shortname}' target='#{protein.shortname}'>"
				  @graphml << "<data key='label'>interacts</data>"
                  @graphml << "<data key='edgetype'>interaction</data>"
				  @graphml << "</edge>"           
              end
          end 
        end        
      end
    else
		@graphml << "<node id='#{protein.shortname}'>"
        @graphml << "<data key='label'>#{protein.recname}</data>"
        @graphml << "<data key='weight'>10.0</data>"
        protein.isprotease ? @graphml << "<data key='nodetype'>protease</data>" : @graphml << "<data key='nodetype'>protein</data>" 
        @graphml << "</node>"
      
      	@log.push("a#{protein.id}")         
    end

    if i == @max || @log.include?("f#{protein.id}") 
      return ''
    else        
      protein.cleavages.each do |c|
      	next if self.filtered && (self.evidences & c.evidences.*.id).blank?
        add_nodes(protein,c.substrate,'cleavage',i+1,"#{protein.id}>#{c.substrate.id}") if c.substrate
      end
      protein.inverse_cleavages.each do |c|
      	next if self.filtered && (self.evidences & c.evidences.*.id).blank?
        add_nodes(protein,c.protease,'inverse_cleavage',i+1,"#{c.protease.id}>#{protein.id}") if c.protease
      end
      protein.inhibitions.each do |c|
      	next if self.filtered && (self.evidences & c.evidences.*.id).blank?
        add_nodes(protein,c.inhibitor,'inhibition',i+1,"#{c.inhibitor.id}|#{protein.id}") if c.inhibitor
      end
      protein.inverse_inhibitions.each do |c|
      	next if self.filtered && (self.evidences & c.evidences.*.id).blank?
        add_nodes(protein,c.inhibited_protease,'inverse_inhibition',i+1,"#{protein.id}|#{c.inhibited_protease.id}") if c.inhibited_protease
      end
      if ppi
        protein.ccs.each do |cc|
          if cc.topic == 'INTERACTION'
            partner = Protein.acs_name_is(cc.contents.match(/\nSP_Ac.*: (.*)\n/)[1]).first
            if partner
              add_nodes(protein,partner,'interaction',i+1,"#{protein.id}-#{partner.id}")
            end
          end
        end 
      end       
      @log.push("f#{protein.id}")                      
    end
  end
  
  
  def add_additional_nodes(nodes,type)
    nodes.each_pair do |shortname,count|
      case type
        when 'cleavage'
          @graphml << "<node id='#{shortname}_a_substrates'>"
          @graphml << "<data key='label'>#{shortname} has #{count} additional substrates</data>"
          @graphml << "<data key='weight'>1.0</data>"
    	  @graphml << "<data key='nodetype'>additional</data>"  
          @graphml << "</node>"
          
          @graphml << "<edge source='#{shortname}' target='#{shortname}_a_substrates'>"
          @graphml << "<data key='label'>cleaves</data>"
          @graphml << "<data key='edgetype'>cleavage</data>"
          @graphml << "</edge>"
                           
        when 'inverse_cleavage'
          @graphml << "<node id='#{shortname}_a_proteases'>"
          @graphml << "<data key='label'>#{shortname} is processed by #{count} more proteases</data>"
          @graphml << "<data key='nodetype'>additional</data>" 
          @graphml << "</node>"
          
          @graphml << "<edge source='#{shortname}_a_proteases' target='#{shortname}'>"
          @graphml << "<data key='label'>cleaves</data>"
          @graphml << "<data key='edgetype'>cleavage</data>"
          @graphml << "</edge>"
          
        when 'inhibition'
          @graphml << "<node id='#{shortname}_a_inhibitors'>"
          @graphml << "<data key='label'>#{shortname} is inhibited by #{count} more inhibitors</data>"
          @graphml << "<data key='nodetype'>additional</data>" 
          @graphml << "</node>"
          
          @graphml << "<edge source='#{shortname}_a_inhibitors' target='#{shortname}'>"
          @graphml << "<data key='label'>inhibits</data>"
          @graphml << "<data key='edgetype'>inhibition</data>"
          @graphml << "</edge>"
          
        when 'inverse_inhibiton'
          @graphml << "<node id='#{shortname}_a_inhibitedproteases'>"
          @graphml << "<data key='label'>#{shortname} inhibits #{count} more proteases</data>"
          @graphml << "<data key='nodetype'>additional</data>" 
          @graphml << "</node>"
          
          @graphml << "<edge source='#{shortname}_a_inhibitedproteases' target='#{shortname}'>"
          @graphml << "<data key='label'>inhibits</data>"
          @graphml << "<data key='edgetype'>inhibition</data>"
          @graphml << "</edge>"
        
			  #         when 'interaction' 
			  #           unless @log.include?("#{protein.id}-#{parent.id}")
			  # 
			  # @sif << "#{parent.shortname}\\tinteracts\\t#{protein.shortname}\\n"
			  # 
			  # @graphml << "<node id='#{protein.shortname}'>"
			  # @graphml << "<data key='label'>#{protein.recname}</data>"
			  # @graphml << "<data key='weight'>2.0</data>"
			  # @graphml << "</node>"
			  # 
			  # @graphml << "<edge source='#{parent.shortname}' target='#{protein.shortname}'>"
			  # @graphml << "<data key='label'>interacts</data>"
			  #               @graphml << "<data key='edgetype'>interaction</data>"
			  # @graphml << "</edge>"           
			  #           end
        end        
    end
  end


  ### protein features
  

  
  def simplepanel
    panel = ''
    panel << "<div class='featurepanel' >"
    panel << "<div class='protein' style='width:#{self.protein.aalen}px;'>&nbsp;"
      (self.protein.aalen/100).to_i.times do |i|
        panel << "<div class='tickmark'>#{(i*100+100).to_s}</div>"
      end
      panel << "</div>"
    
    ## plot protein chains
    if self.protein.fts.name_is('CHAIN').present?      
      panel << "<div class='track' style='width:#{self.protein.aalen}px;'>"
      panel << "<div class='tracklable'>Chains:</div>"
      @prevto = 0
      self.protein.fts.name_is('CHAIN').each do |fts|
        flength = fts.to.to_i - fts.from.to_i
        if @prevto >= fts.from.to_i 
          panel << "<br/>"
        end
        @prevto = fts.to.to_i 
        panel << "<a class='chain' style='margin-left:#{fts.from}px; width:#{flength}px;' title='<bold>stable protein chain</bold><br/>position:#{fts.from}-#{fts.to}<br/>evidence: inferred from UniProtKB<br/>#{fts.description}'>&nbsp;</a>" 
      end
      panel << "<div class='clear'>&nbsp;</div></div>"
    end   

    ## plot nterms
    if self.nterms.present?
      panel << "<div class='track' style='width:#{self.protein.aalen}px;'>"
      panel << "<div class='tracklable'>N-termini:</div>" 
      @prevto = 0
      self.nterms.each do |nt|
        if @prevto >= nt.pos.to_i-5
          panel << "<br/>"
        end
        @prevto = nt.pos.to_i
        panel << "<a class='popup nterm #{nt.terminusmodification.kw.to_s.parameterize.to_s}' style='margin-left:#{nt.pos.to_s}px;' title='<strong>N-Terminus:</strong><br/><strong>position:</strong> #{nt.pos.to_s}<br/><strong>modification:</strong> #{nt.terminusmodification.name}<br/><strong>evidence:</strong> #{nt.evidences.*.evidencecodes.*.*.*.name.flatten.join(', ')}' href='/topfind/nterms/#{nt.id}' rel='#overlay'>N</a>" 
      end
      panel << "<div class='clear'>&nbsp;</div></div>"
    end   

    ## plot cterms
    if self.protein.cterms.present?
      panel << "<div class='track' style='width:#{self.protein.aalen}px;'>" 
      panel << "<div class='tracklable'>C-termini:</div>"
      @prevto = 0
      self.cterms.each do |ct|
        if @prevto >= ct.pos-5 
          panel << "<br/>"
        end
        @prevto = ct.pos 
        panel << "<a class='popup cterm #{ct.terminusmodification.kw.to_s.parameterize.to_s}' style='margin-left:#{ct.pos-23}px;' title='<strong>C-Terminus:</strong><br/><strong>position:</strong> #{ct.pos.to_s}<br/><strong>modification:</strong> #{ct.terminusmodification.name}<br/><strong>evidence:</strong> #{ct.evidences.*.evidencecodes.*.*.*.name.flatten.join(', ')}' href='/topfind/cterms/#{ct.id}' rel='#overlay'>C</a>" 
      end
      panel << "<div class='clear'>&nbsp;</div></div>"
          end   

    ## plot cleavages
    if self.inverse_cleavages.present?
      panel << "<div class='track' style='width:#{self.protein.aalen}px;'>" 
      panel << "<div class='tracklable'>Cleavage sites:</div>"      
      @prevto = 0      
      self.inverse_cleavages.each do |c| 
        if @prevto >= c.pos 
          panel << "<br/>"
        end
        @prevto = c.pos  
        panel << "<a class='popup inverse_cleavage' style='margin-left:#{c.pos.to_s}px;' title='Processed by: #{c.protease.shortname} @ AS #{c.pos}' href='/topfind/cleavages/#{c.id}' rel='#overlay'>&nbsp;</a>"       
      end
      panel << "<div class='clear'>&nbsp;</div></div>"
    end

    ## plot domain like features
    unless self.protein.domains.blank?
      panel << "<div class='track' style='width:#{self.protein.aalen}px;'>"
      panel << "<div class='tracklable'>Features:</div>"
      @prevto = 0
      self.protein.domains.each do |fts|
        flength = fts.to.to_i - fts.from.to_i 
        if @prevto >= fts.from.to_i 
          panel << "<br/>"
        end
        @prevto = fts.to.to_i 
        panel << "<a class='domain' style='margin-left:#{fts.from}px; width:#{flength}px;' title='#{fts.name}: #{fts.description} (#{fts.from}-#{fts.to})'>&nbsp;</a>"
      end 
      panel << "<div class='clear'>&nbsp;</div></div>"     
    end   

    ## plot active features
    unless self.protein.active_features.blank?
      panel << "<div class='track' style='width:#{self.protein.aalen}px;'>"
      panel << "<div class='tracklable'>Binding & active sites:</div>"
      @prevto = 0
      self.protein.active_features.each do |fts|
        flength = fts.to.to_i - fts.from.to_i
        if @prevto >= fts.from.to_i 
          panel << "<br/>"
        end
        @prevto = fts.to.to_i 
        panel << "<a class='domain' style='margin-left:#{fts.from}px; width:#{flength}px;' title='#{fts.name}: #{fts.description} (#{fts.from}-#{fts.to})'>&nbsp;</a>" 
      end 
      panel << "<div class='clear'>&nbsp;</div></div>"     
    end

    ## plot variants
    unless self.protein.var_features.blank?
      panel << "<div class='track' style='width:#{self.protein.aalen}px;'>"
      panel << "<div class='tracklable'>Sequence variations:</div>"
      @prevto = 0
      self.protein.var_features.each do |fts|
        flength = fts.to.to_i - fts.from.to_i
        if @prevto >= fts.from.to_i
          panel << "<br/>"
        end
        @prevto = fts.to.to_i 
        panel << "<a class='domain' style='margin-left:#{fts.from}px; width:#{flength}px;' title='#{fts.name}: #{fts.description} (#{fts.from}-#{fts.to})'>&nbsp;</a>" 
      end 
      panel << "<div class='clear'>&nbsp;</div></div>"     
    end

    ## plot topo features
    unless self.protein.topo_features.blank?
      panel << "<div class='track' style='width:#{self.protein.aalen}px;'>"
      panel << "<div class='tracklable'>Topology:</div>"
      @prevto = 0
      self.protein.topo_features.each do |fts|
        flength = fts.to.to_i - fts.from.to_i 
        if @prevto >= fts.from.to_i 
          panel << "<br/>"
        end
        @prevto = fts.to.to_i 
        cssclass = fts.name
        cssclass << "_extra" if fts.description.match('Extracellular')
        cssclass << "_intra" if fts.description.match('Cytoplasmic')
        panel << "<a class='domain #{cssclass}' style='margin-left:#{fts.from}px; width:#{flength}px;' title='#{fts.name}: #{fts.description} (#{fts.from}-#{fts.to})'>&nbsp;</a>"
      end 
      panel << "<div class='clear'>&nbsp;</div></div>"     
    end

    ## plot modification like features
    unless self.protein.mod_features.blank?
      panel << "<div class='track' style='width:#{self.protein.aalen}px;'>"
      panel << "<div class='tracklable'>Modifications:</div>"
      @prevto = 0
      self.protein.mod_features.each do |fts|
        flength = fts.to.to_i - fts.from.to_i
        if @prevto >= fts.from.to_i 
          panel << "<br/>"
        end
        @prevto = fts.to.to_i         
        panel << "<a class='domain' style='margin-left:#{fts.from}px; width:#{flength}px;' title='#{fts.name}: #{fts.description} (#{fts.from}-#{fts.to})'>&nbsp;</a>" 
      end 
      panel << "<div class='clear'>&nbsp;</div></div>"     
    end


  
    
    
    panel << "</div>"
    panel << '<script>jQuery(document).ready(function() {jQuery(".featurepanel a").tooltip({offset:[-10,0]}).dynamic({ bottom: { direction: "down", bounce: true } });})</script>'
    panel
  end
  

  
  def icelogo(filter = '')
    require 'soap/wsdlDriver'

    # URL for the service WSDL
    wsdl = 'http://iomics.ugent.be/icelogoserver/IceLogo.wsdl'
  
    # Get the object from the WSDL
    @dbfetchSrv = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver

    # @dbfetchSrv.wiredump_dev = STDOUT
    seqs = self.cleavagesites.*.try(:seq_x)
    if seqs.count > 1
		filename = "#{self.protein.name}_icelogo#{filter}.svg"
		resp =  @dbfetchSrv.getStaticIceLogo({'lExperimentalSet' => seqs,'lSpecies' => self.protein.species,'lScoringType' => 'percentage', 'lYaxis' => 100,'lStartPosition'=>'-5','lPvalue' => 0.05,'lHeight'=>450,'lWidth'=>450})
			open("#{RAILS_ROOT}/public/images/dynamic/#{filename}", "w") do |file|
			  file.write(resp.getStaticIceLogoReturn)  
			end 
		return  filename 
    end  
           
  end
  
  def self.termini_icelogo(seqs,species='Homo sapiens',search='')
    require 'soap/wsdlDriver'

    # URL for the service WSDL
    wsdl = 'http://iomics.ugent.be/icelogoserver/IceLogo.wsdl'
  
    # Get the object from the WSDL
    @dbfetchSrv = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver

    # @dbfetchSrv.wiredump_dev = STDOUT
    # seqs = self.cleavagesites.*.try(:seq_x)
    filename = "termini_icelogo#{search}.svg"
    resp =  @dbfetchSrv.getStaticIceLogo({'lExperimentalSet' => seqs,'lSpecies' => species,'lScoringType' => 'percentage', 'lYaxis' => 100,'lStartPosition'=>'-5','lPvalue' => 0.5,'lHeight'=>450,'lWidth'=>450})
        open("#{RAILS_ROOT}/public/images/dynamic/#{filename}", "w") do |file|
          file.write(resp.getStaticIceLogoReturn)  
        end 
   return  filename   
           
  end  
  
end