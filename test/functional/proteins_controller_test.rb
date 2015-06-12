require File.dirname(__FILE__) + '/../test_helper'

class ProteinsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_topfinder
   #get(:index, {'query' => 'P39900'})
   get(:topfinder_output)#, {'query' => 'P39900'})
   assert_response :success    

 end
 
 def test_topfinder_output
   get(:index, {'query' => 'P39900'})
   get(:topfinder)#, {'query' => 'P39900'})
   get(:topfinder_output)
   assert_response :success    
 end
end
