class AcknowledgmentsController < ApplicationController

  def acknowledgments
    @here = 6
    @researchers = session[:id]
    if @researchers 
      #Buscando as recomendações(apenas para exibição do menu principal)...
      @affins = Recomenda.where("pesquisador1_id = ? AND metodo_id = 2", @researchers).order('value DESC limit 5')
      @corals = Recomenda.where("pesquisador1_id = ? AND metodo_id = 3", @researchers).order('value DESC limit 5')
    end
  end

end
