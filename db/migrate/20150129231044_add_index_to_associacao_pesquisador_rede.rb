class AddIndexToAssociacaoPesquisadorRede < ActiveRecord::Migration
  def change
    add_index :associacao_pesquisador_rede, :pesquisador_id
    add_index :associacao_pesquisador_rede, :rede_id
  end
end
