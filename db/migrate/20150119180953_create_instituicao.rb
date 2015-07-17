class CreateInstituicao < ActiveRecord::Migration
  def change
    create_table :instituicao do |t|
      t.integer :cidade_estado_pais_id
      t.integer :tipo_instituicao_id
      t.string :nome
    end
  end
end
