class ImportHints < Hobo::ViewHints

  # model_name "My Model"
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2
  documentations = Documentation.all.group_by(&:name)
  name = documentations['i-name'].first.short
  description = documentations['i-description'].first.short
  evidence = documentations['i-evidence'].first.short
  csvfile = documentations['i-csvfile'].first.short

	field_names :name => "Name <img class ='help'  src='/topcat/images/help.png' alt='?' title='#{name}'/>",
				:description => "Description  <img class ='help'  src='/topcat/images/help.png' alt='?' title='#{description}'/>",
				:evidence => "Evidence <img class ='help'  src='/topcat/images/help.png' alt='?' title='#{evidence}'/>",
				:csvfile => "Excel or csv file  <img class ='help'  src='/topcat/images/help.png' alt='?' title='#{csvfile}'/>"
			

end
