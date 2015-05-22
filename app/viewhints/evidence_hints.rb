class EvidenceHints < Hobo::ViewHints

  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2
  documentations = Documentation.all.group_by(&:name)
  name = documentations['e_name'].first.short
  method = documentations['e_method'].first.short
  methodology = documentations['e_methodology'].first.short
  method_system = documentations['e_method_system'].first.short
  method_protease_source = documentations['e_method_protease_source'].first.short
  proteaseassignmentconfidence = documentations['e_proteaseassignment'].first.short
  inhibitors = documentations['e_inhibitors'].first.short
  description = documentations['ne_description'].first.short
  code = documentations['e_code'].first.short
  physrel = documentations['e_physrel'].first.short
  directness = documentations['e_directness'].first.short
  tissue = documentations['e_tissue'].first.short
  evidencefile = documentations['ne_evidencefile'].first.short
  lab = documentations['e_lab'].first.short
  source = documentations['e_source'].first.short
  repository = documentations['e_repository'].first.short
  publications = documentations['ne_publications'].first.short

	field_names :name => "Name <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{name}'/>",
				:method => "Method (if other)  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{method}'/>",
        :methodology => "Method  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{methodology}'/>",
        :method_system => "Experimental system  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{method_system}'/>",
        :method_protease_source => "Protease source (if applicable) <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{method_protease_source}'/>",
        :proteaseassignment_confidence => "Protease assignment confidence (if applicable) <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{proteaseassignmentconfidence}'/>",
        :protease_inhibitors_used => "Protease inhibitors  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{inhibitors}'/>",
				:description => "Description  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{description}'/>",
				:physrelevance => "Physiological relevance  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{physrel}'/>",
				:evidencecodes => "Evidence  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{code}'/>", 
				:evidencesource => "Source (database) <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{source}'/>",
				:directness => "Directness of identification  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{directness}'/>",
				:tissues => "Tissues  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{tissue}'/>",
				:evidencefile => "additional information (pdf file)  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{evidencefile}'/>",
				:lab => "Source (laboratory)  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{lab}'/>",
				:repository => "Raw data repository link  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{repository}'/>",
				:publications => "Publications  <img class ='help'  src='/topfind/images/help.png' alt='?' title='#{publications}'/>"
				
end
