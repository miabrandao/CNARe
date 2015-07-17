class CreateFormacaoAcademica < ActiveRecord::Migration
  def change
    create_table :formacao_academica do |t|
      t.integer :instituicao_formacao_academica_id
      t.integer :tipo_formacao_academica_id
      t.integer :pesquisador_id
      t.date :data_inicio
      t.date :data_fim
      t.text :descricao
    end
  end
end
