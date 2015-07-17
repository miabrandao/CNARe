class CreateCidadeEstadoPais < ActiveRecord::Migration
  def change
    create_table :cidade_estado_pais do |t|
      t.integer :pais_id
      t.integer :estado_id
      t.integer :cidade_id
    end
  end
end
