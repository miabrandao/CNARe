class AddIndexToCidadeEstadoPais < ActiveRecord::Migration
  def change
    add_index :cidade_estado_pais, :pais_id
    add_index :cidade_estado_pais, :estado_id
    add_index :cidade_estado_pais, :cidade_id
  end
end
