class Estado < ActiveRecord::Base
  attr_accessible :id, :nome, :pais_id, :sigla
end
