class Ols < ActiveRecord::Base
  establish_connection :ols
  set_table_name "term"


  
end

class Ols_dbxref < ActiveRecord::Base
  establish_connection :ols
  set_table_name "dbxref"
  
  named_scope :pubmed,  {:conditions => ['`dbname` LIKE "PubMed"'] }
end

class Ols_annotation < ActiveRecord::Base
  establish_connection :ols
  set_table_name "annotation" 

end