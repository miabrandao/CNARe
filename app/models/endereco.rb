class Endereco < ActiveRecord::Base
  attr_accessible :bairro, :cep, :cidade_estado_pais_id, :id, :logradouro
end
