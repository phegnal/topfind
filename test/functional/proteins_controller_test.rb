require File.dirname(__FILE__) + '/../test_helper'

class ProteinsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_pathfinder
    #get(:index, {'query' => 'P39900'})

    get(:pathfinder)#, {'query' => 'P39900'})
    assert_response :success    

  end
  def test_topfinder


    get(:topfinder)#, {'query' => 'P39900'})
    assert_response :success    

  end
  
  def test_topfinder_output

    get(:topfinder_output)
    assert_response :success    

  end
  
  def test_index
     get(:index, {'query' => 'P39900'})
     
     assert_response :redirect, @response.body
  end
  
  def test_show
     get(:show, {'id'=> 'P39900'})
     assert_response :success
   end
   
  def test_filter
     get(:filter, {'id'=> 'P39900'})
     assert_response :success
   end
  def test_apiget
     get(:apiget, {'id'=> 'P39900'})
     assert_response :success
   end
   
end
