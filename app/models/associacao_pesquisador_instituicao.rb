class AssociacaoPesquisadorInstituicao < ActiveRecord::Base
  attr_accessible :data_fim, :data_inicio, :descricao, :endereco_id, :id, :inct_id, :instituicao_id, :pesquisador_id, :tipo_associacao_pesquisador_instituicao_id
end
