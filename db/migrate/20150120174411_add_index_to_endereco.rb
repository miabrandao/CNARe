class AddIndexToEndereco < ActiveRecord::Migration
  def change
    add_index :endereco, :cidade_estado_pais_id
  end
end
