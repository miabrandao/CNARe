class AddIndexToAssociacaoPesquisadorInstituicao < ActiveRecord::Migration
  def change
    add_index :associacao_pesquisador_instituicao, :inct_id
    add_index :associacao_pesquisador_instituicao, :endereco_id
    add_index :associacao_pesquisador_instituicao, :instituicao_id
    add_index :associacao_pesquisador_instituicao, :pesquisador_id
    add_index :associacao_pesquisador_instituicao, :tipo_associacao_pesquisador_instituicao_id, name: 'my_index'
  end
end
