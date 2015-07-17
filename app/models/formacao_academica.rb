class FormacaoAcademica < ActiveRecord::Base
  attr_accessible :data_fim, :data_inicio, :descricao, :id, :instituicao_formacao_academica_id, :pesquisador_id, :tipo_formacao_academica_id
end
