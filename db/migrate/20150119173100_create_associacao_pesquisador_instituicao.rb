class CreateAssociacaoPesquisadorInstituicao < ActiveRecord::Migration
  def change
    create_table :associacao_pesquisador_instituicao do |t|
      t.integer :inct_id
      t.integer :endereco_id
      t.integer :instituicao_id
      t.integer :pesquisador_id
      t.integer :tipo_associacao_pesquisador_instituicao_id
      t.string :descricao
      t.date :data_inicio
      t.date :data_fim
    end
  end
end
