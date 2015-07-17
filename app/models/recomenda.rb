class Recomenda < ActiveRecord::Base
  attr_accessible :id, :metodo_id, :neighborhood, :pesquisador1_id, :pesquisador2_id, :value
  belongs_to :pesquisador
  belongs_to :pesquisador2, :class_name => "Pesquisador"
end
