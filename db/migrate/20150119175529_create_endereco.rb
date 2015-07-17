class CreateEndereco < ActiveRecord::Migration
  def change
    create_table :endereco do |t|
      t.integer :cidade_estado_pais_id
      t.text :logradouro
      t.string :bairro
      t.string :cep
    end
  end
end
