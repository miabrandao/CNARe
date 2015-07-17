class AddIndexToInstituicao < ActiveRecord::Migration
  def change
    add_index :instituicao, :cidade_estado_pais_id
    add_index :instituicao, :tipo_instituicao_id
  end
end
