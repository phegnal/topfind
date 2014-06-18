class ChainsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  
  def show
    @chain = find_instance
    @features = @chain.fts.present(@chain.nterm.pos,@chain.cterm.pos).description_is_not(@chain.name)
    @absent_features = @chain.fts.absent(@chain.nterm.pos,@chain.cterm.pos).description_is_not(@chain.name)

  end

end
