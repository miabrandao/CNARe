class CreatePesquisador < ActiveRecord::Migration
  def change
    create_table :pesquisador do |t|
      t.string :nome
      t.string :nomeDsc
      t.string :url_lattes
      t.string :url_lattes_oficial
      t.date :data_coleta_lattes
      t.integer :nivel_coleta
      t.date :ult_data_atualizacao_lattes
      t.string :sexo
      t.text :area
      t.string :instituicao
      t.integer :selecao
    end
  end
end
