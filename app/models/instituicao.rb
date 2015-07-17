class Instituicao < ActiveRecord::Base
  attr_accessible :acronimo, :cidade_estado_pais_id, :id, :nome, :tipo_instituicao_id
end
