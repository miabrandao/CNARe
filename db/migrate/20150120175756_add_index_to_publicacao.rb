class AddIndexToPublicacao < ActiveRecord::Migration
  def change
    add_index :publicacao, :autor_citacao_id
    add_index :publicacao, :publicacao_replica_id
    add_index :publicacao, :edicao_id
    add_index :publicacao, :tipo_publicacao_id
  end
end
