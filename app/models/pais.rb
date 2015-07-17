class Pais < ActiveRecord::Base
  attr_accessible :id, :iso, :iso3, :nome, :num_code
end
