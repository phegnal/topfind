class Go < ActiveRecord::Base 
  establish_connection :go
  set_table_name "term"
  
  has_many :gopaths, :foreign_key => "term1_id"
  has_many :inverse_gopaths, :class_name => "Gopath", :foreign_key => "term2_id"
  has_many :children, :through => :gopaths, :foreign_key => "term2_id", :conditions => "distance = 1"
  has_many :ancestors, :through => :inverse_gopaths, :foreign_key => "term1_id", :conditions => 'distance = 1'
     
  has_many :goterm_synonymes, :foreign_key => 'term_id'
  has_one :goterm_definition, :foreign_key => 'term_id'
  
  def self.update_terms
    puts 'Function'
    Go.term_type_is('molecular_function').each do |f|
      node = Gofunction.find_or_create_by_acc(f.acc)
      node.save
      node = Gofunction.update(node.id, {:name => f.name, :description => f.goterm_definition.term_definition, :is_obsolete => (f.is_obsolete == 1)})
    end
    puts 'Component'
    Go.term_type_is('cellular_component').each do |f|
      node = Gocomponent.find_or_create_by_acc(f.acc)
      node.save
      Gocomponent.update(node.id, {:name => f.name, :description => f.goterm_definition.term_definition, :is_obsolete => (f.is_obsolete == 1)})
    end
    'Puts Process'
    Go.term_type_is('biological_process').all.each do |f|
      node = Goprocess.find_or_create_by_acc(f.acc)
      node.save
      Goprocess.update(node.id, {:name => f.name, :description => f.goterm_definition.term_definition, :is_obsolete => (f.is_obsolete == 1)})
     end    
  end
  
  def self.update_graph
    Gopath.distance_is(1).each do |p|
      acc_from = Go.find(p.term1_id)
      acc_to = Go.find(p.term2_id)
      case acc_from.term_type
        when 'molecular_function'
          from = Gofunction.find_by_acc(acc_from)
          to = Gofunction.find_by_acc(acc_to)
          Golink.create_edge(from,to)
        when 'cellular_component'
          from = Gocomponent.find_by_acc(acc_from)
          to = Gocomponent.find_by_acc(acc_to)
          Golink.create_edge(from,to)
        when 'molecular_process'
          from = Gprocess.find_by_acc(acc_from)
          to = Goprocess.find_by_acc(acc_to)
          Golink.create_edge(from,to) 
       end 
    end
  end
  
  # def traces
  #   trace = []
  #   trace2goterms.each do |tg|
  #     trace << tg.trace
  #   end
  #   trace
  # end 
  # 
  # def gomenu
  #   menu = Array.new
  #   menu.push(node(self))
  #   menu
  # end
  # 
  # def node (term)
  #     node = Array.new
  #     node.push(term.name)
  #     node.push(term.acc)
  #     unless term.children.empty? 
  #       term.children.each do |c|
  #       node.push(node(c))
  #       end
  #     end
  #     node      
  # end
     
  
end

class Gopath < ActiveRecord::Base
  establish_connection :go
  set_table_name "graph_path"
  
  belongs_to :children, :class_name => "Goterm", :foreign_key => "term2_id", :conditions => "is_obsolete = 0"
  belongs_to :ancestor, :class_name => "Goterm", :foreign_key => "term1_id", :conditions => "is_obsolete = 0"
  
    
end

class GotermSynonyme < ActiveRecord::Base
  establish_connection :go
  set_table_name "term_synonym"
  
  belongs_to :goterm, :foreign_key => 'term_id'
  
end

class GotermDefinition < ActiveRecord::Base
  establish_connection :go
  set_table_name "term_definition"
  
  belongs_to :goterm, :foreign_key => 'term_id'
  
end
